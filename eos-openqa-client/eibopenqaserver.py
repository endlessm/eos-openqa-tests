# -*- mode: Python; coding: utf-8 -*-

# Endless image builder library — OpenQA server utilities
#
# Copyright © 2018  Endless Mobile, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

from configparser import ConfigParser
import hashlib
import hmac
import logging
import os
import requests
import time

# OpenQA server hostname.
OPENQA_SERVER_HOST = 'openqa.endlessos.org'
# URI providing help on client.conf.
OPENQA_CLIENT_HELP_URI = 'http://open.qa/docs/#_using_the_client_script'

logger = logging.getLogger(__name__)


class OpenQAError(Exception):
    pass


def get_client_config_path():
    """Retrieve the openQA client config file path"""
    xdg_config_home = os.environ.get(
        'XDG_CONFIG_HOME',
        os.path.expanduser('~/.config'),
    )
    return os.path.join(xdg_config_home, 'openqa', 'client.conf')


def get_credentials(host=OPENQA_SERVER_HOST):
    """Retrieve openQA API credentials

    The credentials are first from the environment variables
    OPENQA_API_KEY and OPENQA_API_SECRET. If those are not set, the key
    and secret are read from the ~/.config/openqa/client.conf file.
    """
    api_key = os.environ.get('OPENQA_API_KEY')
    api_secret = os.environ.get('OPENQA_API_SECRET')
    if api_key and api_secret:
        logger.info('Using credentials from environment variables')
    else:
        # Try and load the config. It’s typically at
        # ~/.config/openqa/client.conf, and contains key= and secret=
        # keys in sections indexed by hostname. For example:
        #
        #    [openqa.endlessm.com]
        #    key=DEADBEEF
        #    secret=A150DEADBEEF
        #
        # See http://open.qa/docs/#_using_the_client_script.
        conf_path = get_client_config_path()

        logger.debug(f'Reading client config file {conf_path}')
        conf = ConfigParser()
        conf.read(conf_path)
        api_key = conf.get(host, 'key', fallback=None)
        api_secret = conf.get(host, 'secret', fallback=None)
        if api_key and api_secret:
            logger.info('Using credentials from client config file')

    if not api_key and api_secret:
        raise OpenQAError('Could not find openQA API credentials')

    return (api_key, api_secret)


def remap_arch(eib_arch):
    """OpenQA has specific ideas about what architectures should be"""
    mappings = {
        'amd64': 'x86_64',
        'armhf': 'arm',
    }
    return mappings[eib_arch] if eib_arch in mappings else eib_arch


def send_request_for_image(image_type, image_url, manifest,
                           host=OPENQA_SERVER_HOST,
                           api_key=None,
                           api_secret=None,
                           update_to_manifest=None,
                           dry_run=False):
    openqa_endpoint_url = f'https://{host}/api/v1/isos'

    if not api_key or not api_secret:
        api_key, api_secret = get_credentials(host)

    # Work out which apps are installed on the image.
    image_flatpak_remotes = manifest['flatpak']['remotes'].keys()
    image_flatpak_runtimes = manifest['flatpak']['runtimes'].keys()
    image_flatpak_apps = manifest['flatpak']['apps'].keys()

    # Work out which locales were set on an image
    image_flatpak_locales = manifest['flatpak_locales']

    # Get the OSTree collection ID.
    image_ostree_collection_id = manifest['ostree'].get('collection-id', '')

    # Construct the flavor. This needs to include everything else that we want
    # to differentiate on (aside from the branch, build_version, arch, product
    # and platform, which are keyed separately). In particular, the
    # personality, image type, and update path. We can’t include the actual
    # update version in the FLAVOR, since that would mean the `templates` file
    # in eos-openqa-tests.git would need updating for each release.
    flavor = '{}_{}{}'.format(manifest['personality'], image_type,
                              '_update' if update_to_manifest else '')

    # Build an API request to send to OpenQA to add the new disk image to its
    # list of images, and hence instantiate tests from the job templates for
    # it. See the API documentation at http://openqa.endlessm.com/api_help.
    #
    # We might expect to be called with variable values like the following:
    #     EIB_IMAGE_LANGUAGE= EIB_PLATFORM=amd64 EIB_ARCH=amd64
    #     EIB_PERSONALITY=base EIB_BUILD_VERSION=180807-224735 EIB_PRODUCT=eos
    #     EIB_BRANCH=master
    #     EIB_IMAGE_URL=http://images-dl.endlessm.com/nightly/eos-amd64-amd64/
    #         master/base/180807-224735/
    #     EIB_OUTVERSION=eos-master-amd64-amd64.180807-224735.base
    #
    # The resulting request will be essentially equivalent to running:
    #     openqa-client --host openqa.endlessm.com isos post \
    #         ISO_URL=blah DISTRI=blas FLAVOR=blarf …
    #
    # Note that the request parameters have to be encoded in the URI, rather
    # than the payload, so they are part of the request hash (X-API-Hash) and
    # hence cannot be replayed elsewhere.
    data = {
        # OpenQA keys
        'VERSION': manifest['branch'],
        'BUILD': manifest['build_version'],
        'DISTRI': manifest['product'],
        'FLAVOR': flavor,
        'ARCH': remap_arch(manifest['arch']),
        # Custom keys, just to add a bit more metadata
        'EOS_PLATFORM': manifest['platform'],
        'EOS_IMAGE_FLATPAK_REMOTES': ' '.join(image_flatpak_remotes),
        'EOS_IMAGE_FLATPAK_RUNTIMES': ' '.join(image_flatpak_runtimes),
        'EOS_IMAGE_FLATPAK_APPS': ' '.join(image_flatpak_apps),
        'EOS_IMAGE_FLATPAK_LOCALES': ' '.join(image_flatpak_locales),
        'EOS_IMAGE_OSTREE_COLLECTION_ID': image_ostree_collection_id,
        'EOS_IMAGE_OSTREE_COMMIT': manifest['ostree']['commit'],
        'EOS_IMAGE_OSTREE_DATE': manifest['ostree']['date'],
        'EOS_IMAGE_OSTREE_REF': manifest['ostree']['ref'],
        'EOS_IMAGE_OSTREE_REMOTE': manifest['ostree']['remote'],
        'EOS_IMAGE_TYPE': image_type,
    }
    if 'image_language' in manifest:
        data['EOS_IMAGE_LANGUAGE'] = manifest['image_language']
    if update_to_manifest:
        try:
            collection_id = update_to_manifest['ostree']['collection-id']
        except KeyError:
            collection_id = ''

        if (
            collection_id == 'com.endlessm.Dev' or
            collection_id.startswith('com.endlessm.Dev.')
        ):
            os_update_to_stage = 'dev'
        elif (
            collection_id == 'com.endlessm.Demo' or
            collection_id.startswith('com.endlessm.Demo.')
        ):
            os_update_to_stage = 'demo'
        else:
            os_update_to_stage = 'prod'

        data['OS_UPDATE_TO'] = update_to_manifest['ostree']['version']
        data['OS_UPDATE_TO_STAGE'] = os_update_to_stage

    # Add the image URI.
    if image_type == 'iso':
        data['ISO_URL'] = image_url
    elif image_type == 'full':
        data['HDD_1_DECOMPRESS_URL'] = image_url
    else:
        raise ValueError('Unknown image type ‘%s’' % image_type)

    logger.debug('openQA request data:\n%s', data)

    request = requests.Request('POST', openqa_endpoint_url)
    request.data = data
    request = request.prepare()

    # Request hashing copied from openQA-python-client:
    # https://github.com/os-autoinst/openQA-python-client/blob/master/openqa_client/client.py
    # (it seemed pointless to pull in a full dependency on it for just this).
    timestamp = time.time()
    path = request.path_url.replace('%20', '+').replace('~', '%7E')
    api_hash = hmac.new(
        api_secret.encode(),
        '{0}{1}'.format(path, timestamp).encode(),
        hashlib.sha1,
    )

    headers = {
        'Accept': 'application/json',
        'X-API-Microtime': str(timestamp).encode(),
        'X-API-Key': api_key,
        'X-API-Hash': api_hash.hexdigest(),
    }
    request.headers.update(headers)
    logger.debug('Sending OpenQA request to %s', request.url)

    # If doing a dry run, bail before sending the request
    if dry_run or os.environ.get('EIB_DRY_RUN', None) == 'true':
        logger.info('Dry run: would have POSTed request to %s', request.url)
        return

    # Send the request
    with requests.Session() as session:
        response = session.send(request)

    logger.debug('OpenQA response status: %d', response.status_code)
    logger.debug('OpenQA response headers: %s', response.headers)
    logger.debug('OpenQA response content: %s', response.content)

    # Raise an error if the server complained
    response.raise_for_status()

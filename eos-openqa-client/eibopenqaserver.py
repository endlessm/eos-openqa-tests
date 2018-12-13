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

import eibimageserver
import hashlib
import hmac
import logging
import os
import requests
import time
import sys

logger = logging.getLogger(__name__)


def remap_arch(eib_arch):
    """OpenQA has specific ideas about what architectures should be"""
    mappings = {
        'amd64': 'x86_64',
        'armhf': 'arm',
    }
    return mappings[eib_arch] if eib_arch in mappings else eib_arch


def send_request_for_manifest(manifest, image, upload_api_host,
                              openqa_endpoint_url, api_key, api_secret,
                              update_to_manifest=None, dev_password=None):
    image_details = manifest['images'][image]

    download_url = \
        'nightly/{product}-{arch}-{platform}/{branch}/{personality}/{build_version}'.format(**manifest)
    image_url = 'http://{}/{}/{}'.format(upload_api_host, download_url,
                                         image_details['file'])

    # Work out which apps are installed on the image.
    image_flatpak_remotes = manifest['flatpak']['remotes'].keys()
    image_flatpak_runtimes = manifest['flatpak']['runtimes'].keys()
    image_flatpak_apps = manifest['flatpak']['apps'].keys()

    # Get the OSTree collection ID.
    image_ostree_collection_id = manifest['ostree'].get('collection-id', '')

    # Construct the flavor. This needs to include everything else that we want
    # to differentiate on (aside from the branch, build_version, arch, product
    # and platform, which are keyed separately). In particular, the
    # personality, image type, and update path. We can’t include the actual
    # update version in the FLAVOR, since that would mean the `templates` file
    # in eos-openqa-tests.git would need updating for each release.
    flavor = '{}_{}{}'.format(manifest['personality'], image,
                              '_update' if update_to_manifest else '')

    # Build an API request to send to OpenQA to add the new disk image to its
    # list of images, and hence instantiate tests from the job templates for
    # it. See the API documentation at http://openqa.dev.endlessm.com/api_help.
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
    #     openqa-client --host openqa.dev.endlessm.com isos post \
    #         ISO_URL=blah DISTRI=blas FLAVOR=blarf …
    #
    # Note that the request parameters have to be encoded in the URI, rather than
    # the payload, so they are part of the request hash (X-API-Hash) and hence
    # cannot be replayed elsewhere.
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
        'EOS_IMAGE_OSTREE_COLLECTION_ID': image_ostree_collection_id,
        'EOS_IMAGE_OSTREE_COMMIT': manifest['ostree']['commit'],
        'EOS_IMAGE_OSTREE_DATE': manifest['ostree']['date'],
        'EOS_IMAGE_OSTREE_REF': manifest['ostree']['ref'],
        'EOS_IMAGE_OSTREE_REMOTE': manifest['ostree']['remote'],
        'EOS_IMAGE_TYPE': image,
    }
    if 'image_language' in manifest:
        data['EOS_IMAGE_LANGUAGE'] = manifest['image_language']
    if update_to_manifest:
        try:
            collection_id = update_to_manifest['ostree']['collection-id']
        except KeyError:
            collection_id = ''

        if collection_id == 'com.endlessm.Dev' or \
           collection_id.startswith('com.endlessm.Dev.'):
            os_update_to_stage = 'dev'
            os_update_to_stage_password = dev_password
        elif collection_id == 'com.endlessm.Demo' or \
             collection_id.startswith('com.endlessm.Demo.'):
            os_update_to_stage = 'demo'
            os_update_to_stage_password = ''
        else:
            os_update_to_stage = 'prod'
            os_update_to_stage_password = ''

        data['OS_UPDATE_TO'] = update_to_manifest['ostree']['version']
        data['OS_UPDATE_TO_STAGE'] = os_update_to_stage
        data['OS_UPDATE_TO_STAGE_PASSWORD'] = os_update_to_stage_password

    # Add the image URI.
    if image == 'iso':
        data['ISO_URL'] = image_url
    elif image == 'full':
        data['HDD_1_DECOMPRESS_URL'] = image_url
    else:
        raise ValueError('Unknown image ‘%s’' % image)

    request = requests.Request('POST', openqa_endpoint_url)
    request.data = data
    request = request.prepare()

    # Request hashing copied from openQA-python-client:
    # https://github.com/os-autoinst/openQA-python-client/blob/master/openqa_client/client.py
    # (it seemed pointless to pull in a full dependency on it for just this).
    timestamp = time.time()
    path = request.path_url.replace('%20', '+').replace('~', '%7E')
    api_hash = hmac.new(api_secret.encode(),
                        '{0}{1}'.format(path, timestamp).encode(), hashlib.sha1)

    headers = {
        'Accept': 'application/json',
        'X-API-Microtime': str(timestamp).encode(),
        'X-API-Key': api_key,
        'X-API-Hash': api_hash.hexdigest(),
    }
    request.headers.update(headers)
    logger.debug('Sending OpenQA request to %s', request.url)

    # If doing a dry run, bail before sending the request
    if os.environ.get('EIB_DRY_RUN', None) == 'true':
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

# -*- mode: Python; coding: utf-8 -*-

# Endless image builder library — image server utilities
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

import codecs
from contextlib import closing
import json
import logging
import os
import time
try:
    import secretstorage
    HAVE_SECRETSTORAGE = True
except ImportError:
    HAVE_SECRETSTORAGE = False
from urllib.parse import urlencode, urljoin
from urllib.request import urlopen

IMAGE_SERVER_HOST = 'images.endlessos.org'

logger = logging.getLogger(__name__)


class ImageError(Exception):
    pass


def get_token(host=IMAGE_SERVER_HOST):
    """Retrieve image server API token

    The token is first retrieved from the environment variable
    IMAGE_SERVER_TOKEN. If that is not set, the token is read from the the
    keyring using the attribute "service" set to the image server hostname.
    Reading from the keyring is only possible when the secretstorage module is
    available.
    """
    token = os.environ.get('IMAGE_SERVER_TOKEN')
    if token:
        logger.info('Using token from environment variables')
    elif not HAVE_SECRETSTORAGE:
        logger.warning('secretstorage module not available')
    else:
        with closing(secretstorage.dbus_init()) as conn:
            collection = secretstorage.get_default_collection(conn)
            attrs = {'service': host}
            item = next(collection.search_items(attrs), None)
            if item:
                logger.info('Using token from keyring')
                if item.is_locked():
                    item.unlock()
                token = item.get_secret().decode('utf-8')

    if not token:
        raise ImageError('Could not find image server API token')

    return token


def query_images(config, product=None, branch=None, arch=None, platform=None,
                 personality=None, version=None, release=None,
                 min_version=None, max_version=None):
    """
    Query the image server for images matching the given parameters.
    If a parameter is not specified, no filtering is done by that parameter.
    If `release` is specified, it must be boolean: specifying `None` for it
    means no filtering is done by release status.
    If `config` is not provided, the current config from eib is used.
    """

    # Construct image server API URL
    params = {}

    if product:
        params['product'] = product
    if branch:
        params['branch'] = branch
    if arch:
        params['arch'] = arch
    if platform:
        params['platform'] = platform
    if personality:
        params['personality'] = personality
    if release is not None:
        params['release'] = 'true' if release else 'false'
    if version:
        params['version'] = version
    if min_version:
        params['min_version'] = min_version
    if max_version:
        params['max_version'] = max_version

    url_root = config['image']['upload_api_url_root']
    url = urljoin(url_root, '/api/image?' + urlencode(params))

    def fetch_info(url, reader):
        with urlopen(url) as f:
            return json.load(reader(f))

    logger.info('Fetching image info from %s', url)
    reader = codecs.getreader('utf-8')
    info = retry(fetch_info, url, reader)

    if not isinstance(info, list):
        raise Exception('JSON returned from images is not list')

    if len(info) == 0:
        # No previous builds for this variant, so trigger a new build
        logger.info('No previous builds found for configuration')
        return []

    return info


def retry(func, *args, max_retries=3, timeout=1, **kwargs):
    """Retry a function in case of intermittent errors"""
    retry = 0
    while True:
        try:
            return func(*args, **kwargs)
        except:  # noqa: E722
            retry += 1
            if retry > max_retries:
                logger.error('Failed %d retries; giving up', max_retries)
                raise

            # Show the traceback so the error isn't hidden
            logger.warning('Retrying attempt %d', retry, exc_info=True)
            time.sleep(timeout)


def download_image_file(image_info, personality, file_suffix):
    """
    Get a network object for a file in the given `image_info`.
    The first file with suffix `.file_suffix` from the given `personality` will
    be returned. If no such file is found, an Exception will be raised.
    """
    # Find the URI to the file with the given suffix
    latest_url_root = image_info['url']
    latest_suffixed_url = None
    for filename in image_info['personality_files'][personality]:
        if filename.endswith('.' + file_suffix):
            latest_suffixed_url = urljoin(latest_url_root + '/', filename)

    if not latest_suffixed_url:
        raise Exception('No %s in latest build results' % file_suffix)

    # Return a handle to the file
    logger.info('Downloading latest %s from %s', file_suffix,
                latest_suffixed_url)
    return urlopen(latest_suffixed_url)


def download_image_config(image_info, personality):
    """download_image_file() with suffix set to `config.ini`."""
    return download_image_file(image_info, personality, 'config.ini')


def download_image_manifest(image_info, personality):
    """download_image_file() with suffix set to `manifest.json`."""
    return download_image_file(image_info, personality, 'manifest.json')

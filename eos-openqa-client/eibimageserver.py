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

from contextlib import closing
import logging
import os
import requests
try:
    import secretstorage
    HAVE_SECRETSTORAGE = True
except ImportError:
    HAVE_SECRETSTORAGE = False

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


def query_api(path, host=None, token=None, **params):
    """Query image server API"""
    if host is None:
        host = IMAGE_SERVER_HOST
    if token is None:
        token = get_token(host)

    url = f'https://{host}{path}'
    headers = {
        'Accept': 'application/json',
        'Authorization': f'Token {token}',
    }

    logger.info(f'Requesting image API {url}')
    with requests.get(url, headers=headers, params=params) as resp:
        resp.raise_for_status()
        return resp.json()


def query_builds(host=None, token=None, release=False, **kwargs):
    """Query image server builds"""
    params = {'type': '2' if release else '1'}
    params.update(kwargs)
    return query_api('/api/v1/builds/', host=host, token=token, **params)


def query_manifest(id, host=None, token=None):
    """Query image server build manifest"""
    return query_api(f'/api/v1/builds/{id}/manifest', host=host, token=token)


def query_file(path, host=None, token=None):
    """Query image server file"""
    return query_api(f'/api/v1/files/{path}', host=host, token=token)

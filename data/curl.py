#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright © 2018 Endless Mobile, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

import argparse
import requests


def main():
    # Expected usage (from testapi.pm):
    #    curl --form upload=@/tmp/var_log.tar.gz \
    #         --form upname=install_flatpak-var_log.tar.gz \
    #         http://some/url/var_log.tar.gz
    parser = argparse.ArgumentParser(
        description='Simple Python implementation of curl for systems under '
                    'test in OpenQA which don’t have curl installed.')
    parser.add_argument('--form', metavar='KEY=VALUE', type=str,
                        action='append',
                        help='form field to upload (can be specified multiple '
                             'times)')
    parser.add_argument('uri', metavar='URI', type=str,
                        help='URI to upload to')

    args = parser.parse_args()

    files = {}
    data = {}

    for form in args.form:
        key, value = form.split('=', 2)

        if value[0] == '@':
            # File upload
            filename = value[1:]
            files[key] = (filename, open(filename, 'rb'))
        else:
            # Data
            data[key] = value

    requests.post(args.uri, files=files, data=data)


if __name__ == '__main__':
    main()

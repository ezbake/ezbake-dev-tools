#!/usr/bin/env python2.6

#   Copyright (C) 2013-2014 Computer Sciences Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

from __future__ import print_function

import argparse
import fnmatch
import os
import platform
from pprint import pformat
import re

import requests
import rpm


SNAPSHOT_RE = r'SNAPSHOT|\d{14}'


def str_to_auths(s):
    """Converts a user:pass string to a tuple"""
    parts = s.split(':')
    if len(parts) != 2:
        raise ValueError('Invalid auths string. Should be user:pass')

    return tuple(parts)


def url_join(*parts):
    """Join components of a URL"""
    return '/'.join(part.strip('/') for part in parts)


def get_rpms(root_dir):
    """Gather all RPMs within the given directory (recursively)"""
    rpm_paths = []
    for root, _, files in os.walk(root_dir):
        for rpm_path in fnmatch.filter(files, '*.rpm'):
            rpm_paths.append(os.path.join(root, rpm_path))

    return rpm_paths


def read_rpm_header(rpm_path):
    """Reads RPM header/metadata from the given RPM"""
    rpm_ts = rpm.TransactionSet()
    with open(rpm_path, 'rb') as rpm_file:
        return rpm_ts.hdrFromFdno(rpm_file)


def is_snapshot_rpm(rpm_hdr):
    """
    Returns True if the RPM with the given header is for a snapshot, else False
    """
    return re.match(SNAPSHOT_RE, rpm_hdr['release']) is not None


def create_yum_path(rpm_hdr):
    """
    Creates an appropriate path relative to the Yum repo root for the RPM with
    the given header
    """
    # Get Linux distro info to create paths
    distro_info = platform.linux_distribution(full_distribution_name=False)
    distro_name = distro_info[0]
    distro_version = distro_info[1]
    distro_major_version = distro_version.split('.')[0]

    if not distro_name:
        raise RuntimeError('This appears to not be a Linux system!')
    elif distro_name not in ('redhat', 'centos'):
        raise RuntimeError('Unsupported Linux distro "%s"' % distro_name)

    yum_distro = 'el'
    yum_release_type = 'snapshots' if is_snapshot_rpm(rpm_hdr) else 'releases'

    return url_join(
        yum_release_type, yum_distro, distro_major_version,
        rpm_hdr['arch'], 'Packages')


def create_deploy_url(base_url, repo_name, rpm_path, rpm_hdr):
    """Creates a full deployment URL for the given base URL and RPM info"""
    rpm_basename = os.path.basename(rpm_path)
    yum_path = create_yum_path(rpm_hdr)
    return url_join(base_url, repo_name, yum_path, rpm_basename)


def deploy_rpm(rpm_path, deploy_url, auth):
    """Deploys the RPM at the given path to the deployment URL"""
    with open(rpm_path, 'rb') as rpm_file:
        return requests.put(deploy_url, data=rpm_file, auth=auth)


def get_deployed_snapshots(base_url, repo_name, rpm_hdr, auth):
    """Get all snapshots associated with the given RPM information"""
    yum_path = create_yum_path(rpm_hdr)

    query_url = (
        '%s/api/search/pattern?pattern=%s:%s/%s-%s-SNAPSHOT*.rpm' % (
            base_url, repo_name, yum_path, rpm_hdr['name'],
            rpm_hdr['version']))

    snapshot_info_resp = requests.get(query_url, auth=auth)
    if snapshot_info_resp.status_code != requests.codes.ok:
        raise RuntimeError(
            'Could not get info for existing snapshots for '
            '%s-%s-SNAPSHOT' % (rpm_hdr['name'], rpm_hdr['version']))

    snapshot_files = snapshot_info_resp.json()['files']
    snapshot_files.sort(reverse=True)

    url_prefix = url_join(base_url, repo_name)
    return [url_join(url_prefix, suffix) for suffix in snapshot_files]


def delete_deployed_rpm(rpm_url, auth):
    """Deletes a deployed RPM at the given URL"""
    return requests.delete(rpm_url, auth=auth)


def main(working_dir, base_url, repo_name, auth, num_snapshots):
    """Main function"""
    for rpm_path in get_rpms(working_dir):
        rpm_basename = os.path.basename(rpm_path)

        print('*' * 40)
        print(rpm_basename)
        print('*' * 40)

        rpm_hdr = read_rpm_header(rpm_path)

        deploy_url = create_deploy_url(base_url, repo_name, rpm_path, rpm_hdr)
        print('Deploying %s to %s' % (rpm_basename, deploy_url))
        deploy_resp = deploy_rpm(rpm_path, deploy_url, auth)
        if deploy_resp.status_code != requests.codes.created:
            raise RuntimeError('Failed deploying %s to %s:\n%s' % (
                rpm_basename, deploy_url, pformat(deploy_resp.json())))

        print('Deployed %s:\n%s' % (rpm_basename, pformat(deploy_resp.json())))

        # Perform snapshot management by deleting stale snapshots
        if is_snapshot_rpm(rpm_hdr):
            snapshot_urls = get_deployed_snapshots(
                base_url, repo_name, rpm_hdr, auth)

            print('Found the following snapshot URLs:\n\t%s' %
                  '\n\t'.join(snapshot_urls))

            # Delete stale snapshots (those older than the last N requested)
            for old_snapshot_url in snapshot_urls[num_snapshots:]:
                print('Deleting stale snapshot %s' % old_snapshot_url)
                delete_resp = delete_deployed_rpm(old_snapshot_url, auth)
                if delete_resp.status_code != requests.codes.no_content:
                    raise RuntimeError(
                        'Could not delete stale snapshot %s' % old_snapshot_url)


if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser(
        description='Deploys RPMs to an Artifactory-hosted Yum repo')

    # Required positional arguments
    arg_parser.add_argument(
        'base_url', help='Base URL of the Artifactory server')

    arg_parser.add_argument('repo_name', help='Artifactory repo name/key')

    # Options
    arg_parser.add_argument(
        '-a', '--auth', type=str_to_auths, metavar='USER:PASSWORD',
        help='Authentication info for Artifactory of form user:pass')

    arg_parser.add_argument(
        '-d', '--dir', default=os.getcwd(), help='Directory to search for RPMs')

    arg_parser.add_argument(
        '-s', '--num-snapshots', type=int, default=3,
        help='Number of snapshots to keep')

    args = arg_parser.parse_args()

    main(args.dir, args.base_url, args.repo_name, args.auth, args.num_snapshots)

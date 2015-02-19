#!/usr/bin/env python

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

import os
import xml.etree.ElementTree as ET
import argparse

MODULE_DIR = 'module_dir'
COMMON_DEPS = ['thrift==0.9.1']
EXCLUDED_DEPS = ['libthrift', 'thrift']
PY_DEV_VERSION = "rc1.dev"
NAMESPACE_PKGS = 'namespace_packages'
NAMESPACE_PKG_CONTENTS = """# this is a namespace package
try:
    import pkg_resources
    pkg_resources.declare_namespace(__name__)
except ImportError:
    import pkgutil
    __path__ = pkgutil.extend_path(__path__, __name__)
"""


def make_namespace_packages(start, basepkg=None):
    """Finds all packages that should be namespace packages
    This includes everything that only has an __init__.py file"""
    packages = []
    for dirname, dirnames, filenames in os.walk(start):
        if basepkg and not dirname.startswith(os.path.join(start, basepkg)):
            continue
        py_files = [x for x in filenames if x.endswith('.py')]
        if len(py_files) == 1 and '__init__.py' in filenames:
            package = dirname[len(start + os.path.sep):]
            if package:
                with open(os.path.join(dirname, '__init__.py'), 'wb') as f:
                    f.write(NAMESPACE_PKG_CONTENTS)
                packages.append(package.replace(os.path.sep, '.'))
    return packages


def find_all_packages(start, type):
    """Finds all target/thrift-gen/{type} packages under start directory"""
    package_dir_name = 'target/thrift-gen/{0}'.format(type)
    packages = {}
    for dirname, dirnames, filenames in os.walk(start):
        if dirname.endswith(package_dir_name):
            packages[dirname] = {
                MODULE_DIR: dirname[:dirname.find(package_dir_name)],
                #NAMESPACE_PKGS: make_namespace_packages(dirname, basepkg)
            }
            del dirnames[:]

    return packages


def write_package_file(type, output_dir, pkg_name, pkg_ver, additional_args=None):
    """Reads the template file for the given type and writes out the package file (setup.py, package.json, etc)"""
    if additional_args is None:
        additional_args = []

    if type == 'python':
        template_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "setup.py.template")
        setup_py_file = os.path.join(os.path.abspath(output_dir), "setup.py")
    elif type == 'node':
        template_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "package.json.template")
        setup_py_file = os.path.join(os.path.abspath(output_dir), "package.json")
    else:
        raise ValueError("Type must be on of python or node")

    with open(template_file, 'r') as inf:
        template = inf.read()

    with open(setup_py_file, 'w+') as outf:
        outf.write(template.format(PACKAGE_NAME=pkg_name,
                                   PACKAGE_VERSION=pkg_ver,
                                   PACKAGE_ADDITIONAL_SETUP_ARGS=',\n    '.join(additional_args)))


def parse_pom(pom):
    """Parse a pom file and get out artifact name, version, and dependencies"""
    artifact_name = None
    artifact_version = None

    tree = ET.iterparse(pom)
    for _, el in tree:
        el.tag = el.tag.split('}', 1)[1]
    root = tree.root

    # determine artifact name
    for element in root.findall('./artifactId'):
        artifact_name = element.text
        break

    # determine version number
    for element in root.findall('./version'):
        artifact_version = element.text
        break
    if not artifact_version:
        # take version from the parent
        for version in root.findall('./parent/version'):
            artifact_version = version.text
            break

    # determine dependencies
    dependencies = []
    for element in root.findall('./dependencies/dependency/artifactId'):
        dependencies.append(element.text)

    return artifact_name, artifact_version, dependencies


def version_for_package_type(type, version):
    """Get the appropriate version for the given type from a maven version number"""
    if type == 'python':
        if '-' in version:
            version, specifier = version.split('-')
            if specifier == 'SNAPSHOT':
                version = "{0}{1}".format(version, PY_DEV_VERSION)
    elif type == 'node':
        version_suffix = ''
        if '-' in version:
            # handle snapshot
            version, specifier = version.split('-')
            version_suffix = "-snapshot"
        versions = version.split('.')
        if len(versions) < 3:
            versions.append(0)
        version = '.'.join(str(x) for x in versions) + version_suffix
    return version


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--module', default='.', help='module to generate setup.py for')
    parser.add_argument('-t', '--type', default='python', choices=['python', 'node'], help='type of package to generate')
    return parser.parse_args()


def main(args):
    packages = find_all_packages(args.module, args.type)

    for path, data in packages.iteritems():
        module_dir = data[MODULE_DIR]
        pkg_name, pkg_version, dependencies = parse_pom(os.path.join(module_dir, 'pom.xml'))
        pkg_version = version_for_package_type(args.type, pkg_version)
        dependencies = ["{0}>={1}".format(x, pkg_version) for x in dependencies if x not in EXCLUDED_DEPS]
        dependencies.extend(COMMON_DEPS)

        additional_params = []
        if args.type == 'python':
            namespace_packages = make_namespace_packages(path, 'ezbake')
            additional_params = [
                "install_requires={0}".format(dependencies),
                "namespace_packages={0}".format(namespace_packages)
            ]
            write_package_file(args.type, path, pkg_name, pkg_version, additional_params)
        elif args.type == 'node':
            additional_params = [
                ",\"dependencies\": {0}".format(str(COMMON_DEPS).replace('\'', '"'))
            ]

        print("Generating package for {0}. Name: {1}, Version: {2}".format(module_dir, pkg_name, pkg_version))
        write_package_file(args.type, path, pkg_name, pkg_version, additional_params)

if __name__ == '__main__':
    main(parse_arguments())


#!/bin/bash
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


function build_rpm() {
    spec_file=$1
    rpmbuild --quiet --define="_topdir $PWD/rpmbuild" -bb rpmbuild/SPECS/$spec_file
}

echo "Creating RPM build directories"
mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

echo "Copying sources to RPM sources directory"
cp rpm-tools/macros.ezbake rpmbuild/SOURCES/macros.ezbake

echo "Copying spec files to RPM build directory"
cp rpm-tools/ezbake-rpm-tools.spec rpmbuild/SPECS/ezbake-rpm-tools.spec

echo "Building RPMs"
build_rpm ezbake-rpm-tools.spec

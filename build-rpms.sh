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
    local spec_file=$1
    local ezbake_version=$2
    local is_release_build=$3
    local git_file_last_changed=$4

    rpmbuild \
        --quiet \
        --define="_topdir $PWD/rpmbuild" \
        --define="ezbake_version $ezbake_version" \
        --define="ezbake_release_build $is_release_build" \
        --define="git_file_last_changed $git_file_last_changed" \
        -bb \
        rpmbuild/SPECS/$spec_file
}

echo "Getting Maven project version information"
mvn_proj_version=$(mvn -q \
                  --non-recursive \
                  org.codehaus.mojo:exec-maven-plugin:1.3.1:exec \
                  -Dexec.executable="echo" \
                  -Dexec.args='${project.version}')

ezbake_version=${mvn_proj_version%%-SNAPSHOT}
if [[ $mvn_proj_version = *-SNAPSHOT ]]; then
    is_release_build=0
else
    is_release_build=1
fi

echo "Creating RPM build directories"
mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

echo "Copying sources to RPM sources directory"
cp rpm-tools/macros.ezbake rpmbuild/SOURCES/macros.ezbake

echo "Copying spec files to RPM build directory"
cp rpm-tools/ezbake-rpm-tools.spec rpmbuild/SPECS/ezbake-rpm-tools.spec

echo "Building RPMs"
build_rpm ezbake-rpm-tools.spec $ezbake_version $is_release_build rpm-tools

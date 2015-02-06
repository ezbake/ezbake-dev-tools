#!/bin/bash

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

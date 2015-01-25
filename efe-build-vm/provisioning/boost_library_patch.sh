#!/bin/bash

#this patch can be removed when the installed boost version is 1.45 and greater

REQUIRED_VERSION="104100"
BOOST_VERSION=`grep '#define BOOST_VERSION ' /usr/include/boost/version.hpp | awk '{ print $3 }'`
PATCH_FILE=/vagrant/provisioning/BOOST_json_parser_read.hpp.patch

patch -p0 -N --dry-run --silent < ${PATCH_FILE} 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Boost library needs to be patched"
    if [ $BOOST_VERSION = $REQUIRED_VERSION ]; then
        patch -p0 -N < ${PATCH_FILE}
        echo " - Patched boost library"
    else
        echo " - Fail. Not patching Boost library. Require version $REQUIRED_VERSION. Detected version $BOOST_VERSION"
    fi
fi


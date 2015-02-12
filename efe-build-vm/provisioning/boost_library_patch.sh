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


#!/bin/bash
#   Copyright (C) 2013-2015 Computer Sciences Corporation
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


if [ ! -d rp_env_setup ];then
     mkdir rp_env_setup
fi
cd rp_env_setup

VERSION="3.2.5"
CHECKSUM="b2d88f02bd3a08a9df1f0b0126ebd8dc"

if [ ! -f /usr/local/apache-maven/bin/mvn ];then
    if [ ! -f apache-maven-$VERSION-bin.tar.gz ];then
        wget https://archive.apache.org/dist/maven/maven-3/$VERSION/binaries/apache-maven-$VERSION-bin.tar.gz
        if [ "$CHECKSUM" != "$(md5sum "apache-maven-$VERSION-bin.tar.gz"  | grep --only-matching -m 1 '^[0-9a-f]*')" ];then
            echo "ERROR: invalid maven binary checksum" >&2
            exit 1
        fi
    fi
    if [ -d apache-maven-$VERSION ];then
        rm -rf apache-maven-$VERSION
    fi
    tar xvzf apache-maven-$VERSION-bin.tar.gz
    mv apache-maven-$VERSION /usr/local/apache-maven
    cd ..
else
    echo "maven already installed"
fi


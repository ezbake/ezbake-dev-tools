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


if [ -d rp_env_setup ];
then
    echo "reverse proxy environment setup directory already exists"
else
     mkdir rp_env_setup
fi

cd rp_env_setup

if autoconf --version |grep --quiet 2.69;
then
    echo "autoconf 2.69 already installed"
else
    if [ -f autoconf-2.69.tar.gz ];
    then
        echo "autoconf-2.69.tar.gz exists, skipping download";
    else
        wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
    fi
    if [ -d autoconf-2.69 ];
    then
        rm -rf autoconf-2.69
    fi
    tar xzvf autoconf-2.69.tar.gz
    cd autoconf-2.69
    ./configure 
    make
    sudo make install
fi
cd ..


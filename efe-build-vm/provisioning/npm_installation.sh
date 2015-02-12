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

NODE_VERSION="v0.10.32"
NODE_PACKAGE="node-${NODE_VERSION}"


hash npm &> /dev/null
if [ $? -eq 1 ];then
    echo "Installing node, npm & bower..."
    if [ ! -d ${NODE_PACKAGE} ]; then
        wget http://nodejs.org/dist/${NODE_VERSION}/${NODE_PACKAGE}.tar.gz
        tar xvzf ${NODE_PACKAGE}.tar.gz
    fi
    cd ${NODE_PACKAGE}
    echo ".. installing npm"
    ./configure --prefix=/usr
    make
    sudo make install
    echo ".. installed node `node --version`"
    echo ".. installing bower"
    npm install -g bower
    echo ".. installed bower `bower --version`"
    echo ".. DONE"

    cd ..
else
    echo "npm appears to be installed"
fi

cd ..


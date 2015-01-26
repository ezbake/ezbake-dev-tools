#!/bin/bash

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
    ./configure
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


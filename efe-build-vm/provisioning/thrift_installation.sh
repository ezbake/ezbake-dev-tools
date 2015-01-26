#!/bin/bash

export PATH=/opt/python/opt/python-2.7.6/bin:${PATH}

THRIFT_VERSION="0.9.1"
THRIFT_INSTALLED=$(thrift -version 2>/dev/null | grep -F "${THRIFT_VERSION}" | wc -l)

if [ -d rp_env_setup ];
then
    echo "reverse proxy environment setup directory already exists"
else
     mkdir rp_env_setup
fi

cd rp_env_setup

if [ "${THRIFT_INSTALLED}" -ne 1 ]; then
    if [ -f thrift-${THRIFT_VERSION}.tar.gz ];
    then
        echo "thrift-${THRIFT_VERSION}.tar.gz exists, skipping download";
    else
        wget http://archive.apache.org/dist/thrift/${THRIFT_VERSION}/thrift-${THRIFT_VERSION}.tar.gz
    fi
    if [ -d thrift-${THRIFT_VERSION} ];
    then
        rm -rf thrift-${THRIFT_VERSION}
    fi
    tar xzvf thrift-${THRIFT_VERSION}.tar.gz
    cd thrift-${THRIFT_VERSION}
    patch -p1 < /vagrant/provisioning/thrift_0.9.1_patches_2201_667_1755_2045_2229_.patch
    ./configure --without-ruby
    make
    sudo make install
    cd lib/py
    sudo env PATH=$PATH pip-python install -U .
    cd ../../..
else
    echo "Thrift appears to be installed, skipping Thrift ${THRIFT_VERSION} build"
fi

cd ..


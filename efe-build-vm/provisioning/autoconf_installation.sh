#!/bin/bash

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


#!/bin/bash

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


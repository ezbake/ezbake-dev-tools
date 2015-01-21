#!/bin/bash

if [[ ! -f quickbuild ]]; then
    wget \
        --no-check-certificate \
        -O quickbuild \
        https://raw.github.com/charlessimpson/dist-rpm/master/quickbuild
fi

sh quickbuild \
    rpm-tools/ezbake-rpm-tools.spec \
    rpm-tools/macros.ezbake

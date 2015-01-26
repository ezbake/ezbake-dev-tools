#!/bin/bash
if grep --quiet ezfrontendui /etc/passwd;
then
    echo "ezfrontendui user already exists"
else
    adduser ezfrontendui
fi
if grep --quiet "ezfrontend:" /etc/passwd;
then
    echo "ezfrontend user already exists"
else
    adduser ezfrontend
fi

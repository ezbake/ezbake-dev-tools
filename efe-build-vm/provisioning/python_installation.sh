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


PY_VERSION="2.7.6"

if [ -d rp_env_setup ];
then
    echo "reverse proxy environment setup directory already exists"
else
     mkdir rp_env_setup
fi

cd rp_env_setup

if [ -f /opt/python-$PY_VERSION/bin/python ];
then
    echo "Python $PY_VERSION appears to be installed in /opt, skipping Python build"
else
    if [ -f Python-$PY_VERSION.tgz ];
    then
        echo "Python-$PY_VERSION.tgz exists, skipping download";
    else
        wget https://www.python.org/ftp/python/$PY_VERSION/Python-$PY_VERSION.tgz
    fi
    if [ -d Python-$PY_VERSION ];
    then
        rm -rf Python-$PY_VERSION
    fi
    tar xzvf Python-$PY_VERSION.tgz
    cd Python-$PY_VERSION
    export LD_RUN_PATH=/opt/python-$PY_VERSION/lib
    ./configure --prefix=/opt/python-$PY_VERSION --enable-shared
    make
    sudo make install
    cd ..
fi

export PATH=/opt/python-$PY_VERSION/bin:$PATH


if [[ -n $(ls /opt/python-$PY_VERSION/lib/python2.7/site-packages/setuptools*) ]]; then
    echo "Setuptools appears to be already installed, skipping"
else
    if [ -f setuptools-2.2.tar.gz ]; then
        echo "Setuptools already downloaded"
    else
        wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | sudo env PATH=$PATH /opt/python-$PY_VERSION/bin/python
        sudo env PATH=$PATH easy_install pip
        sudo env PATH=$PATH alternatives --install /usr/bin/pip-python pip-python `which pip` 1
    fi
fi

# set python to the one we just installed for the vagrant user
cd ..
if grep --quiet python .bashrc;
then
    echo "python 2.7 already in path"
else
    echo "export PATH=/opt/python-$PY_VERSION/bin:\${PATH}" >> .bashrc
fi


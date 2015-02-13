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


CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PARENT_REPO=$(git --git-dir /home/vagrant/.sync_git config --get remote.origin.url)
REPO_ROOT=${PARENT_REPO%/*}
REPO_DOMAIN=${REPO_ROOT#*@}
REPO_DOMAIN=${REPO_DOMAIN%:*}

EFE_BRANCH="master"
EFEUI_BRANCH="master"

EFE_REPO_NAME="ezbake-platform-services"
EFEUI_REPO_NAME="ezbake-platform-ui"


#set abort on error
set -e

#prefetch repo domain ssh keys if it doesn't already exist
if [[ ! -n $(ssh-keygen -H -F $REPO_DOMAIN 2>/dev/null) ]];then
    ssh-keyscan -H $REPO_DOMAIN 2>/dev/null >> ~/.ssh/known_hosts
fi


#clone EFE repo if needed
if [ ! -d $EFE_REPO_NAME ];then
    echo "cloning $EFE_REPO_NAME with a sparse checkout of ./efe"
    git init $EFE_REPO_NAME
    cd $EFE_REPO_NAME
    git remote add -f origin $REPO_ROOT/$EFE_REPO_NAME.git
    git config core.sparsecheckout true
    echo "efe/" >> .git/info/sparse-checkout
    git pull origin $EFE_BRANCH
    cd ../
fi
#clone EFEUI repo if needed
if [ ! -d $EFEUI_REPO_NAME ];then
    echo "cloning $EFEUI_REPO_NAME with a sparse checkout of ./efe, ./classificationbanner"
    git init $EFEUI_REPO_NAME
    cd $EFEUI_REPO_NAME
    git remote add -f origin $REPO_ROOT/$EFEUI_REPO_NAME.git
    git config core.sparsecheckout true
    echo "efe/" >> .git/info/sparse-checkout
    echo "classificationbanner/" >> .git/info/sparse-checkout
    git pull origin $EFEUI_BRANCH
    cd ../
fi


##
#run efe builds
echo -e "\nRunning efe builds ..."
cd $EFE_REPO_NAME/efe
./build.sh
mv *.rpm $CUR_DIR/.
cd $CUR_DIR
echo -e "\nDone building efe rpms. RPMs are located in $CUR_DIR"

#run efeui builds
echo -e "\n\nRunning efeui builds ..."
cd $EFEUI_REPO_NAME/efe
./build.sh
mv *.rpm $CUR_DIR/.
cd $CUR_DIR
echo -e "\nDone building efe rpms. RPMs are located in $CUR_DIR"


#
echo -e "DONE"


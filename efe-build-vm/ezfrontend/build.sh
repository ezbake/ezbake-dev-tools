#!/bin/bash

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PARENT_REPO=$(git --git-dir /home/vagrant/.sync_git config --get remote.origin.url)
REPO_ROOT=${PARENT_REPO%/*}

EFE_BRANCH="master"
EFEUI_BRANCH="master"

EFE_REPO_NAME="ezbake-platform-services"
EFEUI_REPO_NAME="ezbake-platform-ui"


#set abort on error
set -e


##EFE
#clone repo if needed
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

#run efe builds
echo -e "\nRunning efe builds ..."
cd $EFE_REPO_NAME/efe
./build.sh
mv *.rpm $CUR_DIR/.
cd $CUR_DIR
echo -e "\nDone building efe rpms. RPMs are located in $CUR_DIR"


##EFE-UI
#clone repo if needed
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

#run efeui builds
echo -e "\n\nRunning efeui builds ..."
cd $EFEUI_REPO_NAME/efe
./build.sh
mv *.rpm $CUR_DIR/.
cd $CUR_DIR
echo -e "\nDone building efe rpms. RPMs are located in $CUR_DIR"


#
echo -e "DONE"


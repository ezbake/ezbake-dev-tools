#!/bin/bash

PUPPET_REPO="http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-10.noarch.rpm"

if which puppet &>/dev/null; then
  echo "puppet is installed. just updating hieradata"
  exit 0
fi

# install puppet repo
repo_tmp=$(mktemp)
curl -so "${repo_tmp}" "${PUPPET_REPO}"
rpm -i --nosignature ${repo_tmp}
rpm -ql puppetlabs-release | grep GPG | xargs rpm --import
rm -rf ${repo_tmp}

# install puppet
rpm -qs --quiet puppet || yum -q -y install puppet

echo "installed puppet"


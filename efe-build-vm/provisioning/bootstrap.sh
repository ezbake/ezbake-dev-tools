#!/bin/bash

git clone https://github.com/sstephenson/rbenv.git /opt/.rbenv
if grep --quiet "/opt/.rbenv/bin:/usr/local/bin:$PATH" /etc/profile.d/rbenv.sh;
then
    echo "rbenv.sh already configured"
else
    echo 'export PATH="/opt/.rbenv/bin:/usr/local/bin:$PATH"' >> /etc/profile.d/rbenv.sh
    echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
fi
git clone https://github.com/sstephenson/ruby-build.git /tmp/ruby-build
/tmp/ruby-build/install.sh

sudo -u vagrant -i sh - <<'EOF'
rb=$(rbenv install -l | grep -E 1.9.3-p[[:digit:]] | tail -n 1)
rbenv install ${rb}
rbenv global ${rb}
gem install bundler
EOF

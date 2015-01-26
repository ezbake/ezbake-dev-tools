class reverseproxy {
  $build_yum = [ "boost", "boost-devel", "python-devel", "libevent", "libevent-devel", "pcre", "pcre-devel", "readline-devel", "mlocate", "vim-enhanced", "tree", "libedit", "libtool", "byacc", "flex", "apr", "apr-devel", "apr-util", "apr-util-devel", ]

  package { $build_yum:
    ensure => latest,
    provider => yum
  }

  package { "pyinstaller":
    ensure => latest,
    provider => pip
  }

  file { "/usr/lib64/libboost_thread.so":
    ensure => link,
    target => "/usr/lib64/libboost_thread-mt.so",
    require => Package["boost", "boost-devel"]
  }

  $maven_exports = {
    'maven home' => { line => 'export M2_HOME=/usr/local/apache-maven' },
    'maven bin' => { line => 'export M2=$M2_HOME/bin', require => file_line['maven home'] },
    'maven path' => { line => 'export PATH=$M2:$PATH', require => file_line['maven bin'] },
  }
  $maven_export_defaults = {
    ensure => present,
    path => '/home/vagrant/.bashrc',
  }
  create_resources(file_line, $maven_exports, $maven_export_defaults)
}


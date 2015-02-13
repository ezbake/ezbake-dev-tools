/*   Copyright (C) 2013-2014 Computer Sciences Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. */

class reverseproxy {
  $build_yum = [ "boost", "boost-devel", "python-devel", "libevent", "libevent-devel", "pcre", "pcre-devel", "readline-devel", "mlocate", "vim-enhanced", "tree", "libedit", "libtool", "byacc", "flex", "apr", "apr-devel", "apr-util", "apr-util-devel", ]

  package { $build_yum:
    ensure => latest,
    provider => yum
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

  file { '/opt/python-2.7.6/bin/pip':
    ensure => present,
  } -> #and then:
  vcsrepo { '/opt/pyinstaller':
    ensure => latest,
    owner => vagrant,
    group => vagrant,
    provider => git,
    source => 'git@github.com:ezbake/pyinstaller.git',
    revision => 'develop'
  } ~> #and then notify:
  exec { 'install custom pyinstaller':
    cwd => '/opt/pyinstaller',
    command => '/opt/python-2.7.6/bin/pip install .',
    refreshonly => true,
  }
}


/*   Copyright (C) 2013-2015 Computer Sciences Corporation
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

class postshellscripts {

  $system_exports = {
    'maven home' => { line => 'export M2_HOME=/usr/local/apache-maven' },
    'maven bin' => { line => 'export M2=$M2_HOME/bin', require => File_line['maven home'] },
    'maven path' => { line => 'export PATH=$M2:$PATH', require => File_line['maven bin'] },
    'ld library path' => { line => 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64:/usr/lib:/usr/local/lib64:/usr/local/lib' },
  }
  $system_export_defaults = {
    ensure => present,
    path => '/home/vagrant/.bashrc',
  }
  create_resources(file_line, $system_exports, $system_export_defaults)

  file { '/opt/python-2.7.6/bin/pip':
    ensure => present,
  } -> #and then:
  vcsrepo { '/opt/pyinstaller':
    ensure => latest,
    owner => vagrant,
    group => vagrant,
    provider => git,
    source => 'https://github.com/ezbake/pyinstaller.git',
    revision => 'develop'
  } ~> #and then notify:
  exec { 'install custom pyinstaller':
    cwd => '/opt/pyinstaller',
    command => '/opt/python-2.7.6/bin/pip install .',
    refreshonly => true,
  }
}


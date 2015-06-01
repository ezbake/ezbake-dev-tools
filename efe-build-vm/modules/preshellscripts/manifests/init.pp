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

class preshellscripts {
  $pkgs = [ "wget", "git", "rpm-build", "zlib-devel", "java-1.7.0-openjdk-devel",
            "vim-enhanced", "openssl-devel", "boost-devel", "python-devel",
            "pcre-devel", "log4cxx-devel", "npm",
            "libtool", "byacc", "flex", /* for thrift build */
          ]

  package { $pkgs:
    ensure => latest,
    provider => yum,
  }

  package { "ruby-devel":
    ensure => latest,
    provider => yum,
    require => Package["zlib-devel"]
  }

  package { "fpm":
    ensure => latest,
    provider => gem,
    require => Package["ruby-devel"]
  }

  exec { "bower":
    command => "npm install -g bower",
    path => "/bin:/usr/bin:/usr/local/bin",
    subscribe => Package["npm"],
    refreshonly => true,
    logoutput => on_failure,
    timeout => 0,
  }

  file { "/usr/lib64/libboost_thread.so":
    ensure => link,
    target => "/usr/lib64/libboost_thread-mt.so",
    require => Package["boost-devel"]
  }

  define ensure_env_value($key, $value, $file="/home/vagrant/.bashrc") {
    #append if key not in profile
    exec { "append $key=$value $file":
      command => "echo 'export $key=$value' >> $file",
      unless => "grep -qe '[[:space:]]*$key[[:space:]]*=' $file",
      path => "/bin:/usr/bin",
      before => Exec["update $key=$value $file"],
    }

    #update if key already exists
    exec { "update $key=$value $file":
      command => "sed -i 's|$key[[:space:]]*=.*$|$key=$value|g' $file",
      unless => "grep -qe '$key=$value' $file",
      path  => "/bin:/usr/bin",
    }
  }

  ensure_env_value { "set java home":
    key => "JAVA_HOME",
    value => "/usr/lib/jvm/java-1.7.0",
  }
}



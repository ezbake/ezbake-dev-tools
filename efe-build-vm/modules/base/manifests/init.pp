class base {
  $build_base = [ "wget", "git", "rpm-build", "zlib-devel", "java-1.7.0-openjdk-devel", "openssl-devel", "boost", "boost-devel" ]

  package { $build_base:
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



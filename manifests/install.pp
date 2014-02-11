class unrealirc::install {
  
  Exec {
    path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
  }

  $filename = 'unreal'
  $archive = "${filename}.tar.gz"
  $configure = "bash configure --with-showlistmodes --with-listen=5 --with-dpath=${unrealirc::install_path} --with-spath=${unrealirc::install_path}/src/ircd --with-nick-history=2000 --with-sendq=3000000 --with-bufferpool=18 --with-permissions=0600 --with-fd-setsize=1024 --enable-dynamic-linking"

  # Create irc user and group
  group { $unrealirc::group:
    ensure  => present,
  }
  user { $unrealirc::group:
    ensure  => present,
    gid     => $unrealirc::group,
    require => Group[$unrealirc::group],
  }

  # Retrieve and unpack unrealirc
  exec { 'download-unrealirc':
    command => "wget ${unrealirc::url} -O /tmp/${archive}",
    cwd     => '/tmp',
    creates => "/tmp/${archive}",
  }

  exec { 'extract-unrealirc':
    command => "tar -xvzf /tmp/${archive}",
    cwd     => '/tmp',
    require => Exec['download-unrealirc'],
  }

  # Move extracted directory to install path
  exec { 'unrealirc-dir':
    command => "mv `ls -d /tmp/*/ | grep -i unreal | awk '{ print $1 }'` ${unrealirc::install_path}",
    creates => "${unrealirc::install_path}",
    require => Exec['extract-unrealirc'],
  }

  # Configure and make unrealircd, with or without ssl enabled
  if $unrealirc::use_ssl {
    package { 'libssl-dev': 
      ensure => present,
    }
    exec { 'make-unrealirc':
      command => "${configure} --enable-ssl && make",
      timeout => 0,
      cwd     => "${unrealirc::install_path}",
      creates => "${unrealirc::install_path}/unreal",
      require => [ Package['libssl-dev'], Exec['unrealirc-dir'] ],
    }
  } else {
    exec { 'make-unrealirc':
      command => "${configure} && make",
      timeout => 0,
      cwd     => "${unrealirc::install_path}",
      creates => "${unrealirc::install_path}/unreal",
      require => Exec['unrealirc-dir'],
    }
  }

  exec { 'chown-unrealirc-dir':
    command => "chown -R ${unrealirc::user}:${unrealirc::group} ${unrealirc::install_path}",
    require => [ Group[$unrealirc::group], User[$unrealirc::user], Exec['make-unrealirc'] ],
  }
}

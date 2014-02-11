class unrealirc::install {
  
  Exec {
    path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
  }

  $filename = 'unreal'
  $archive = "${filename}.tar.gz"

  # Create irc user and group
  $group = $unrealirc::group
  group { $group:
    ensure  => present,
  }

  $user = $unrealirc::user
  user { $user:
    ensure  => present,
    gid     => $group,
    require => Group[$group],
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

  exec { 'make-unrealirc':
    command => "bash configure --with-showlistmodes --with-listen=5 --with-dpath=${unrealirc::install_path} --with-spath=${unrealirc::install_path}/src/ircd --with-nick-history=2000 --with-sendq=3000000 --with-bufferpool=18 --with-permissions=0600 --with-fd-setsize=1024 --enable-dynamic-linking && make",
    timeout => 0,
    cwd     => "${unrealirc::install_path}",
    creates => "${unrealirc::install_path}/unreal",
    require => Exec['unrealirc-dir'],
  }

  exec { 'chown-unrealirc-dir':
    command => "chown -R ${unrealirc::user}:${unrealirc::group} ${unrealirc::install_path}",
    require => [ Group[$group], User[$user], Exec['make-unrealirc'] ],
  }
}

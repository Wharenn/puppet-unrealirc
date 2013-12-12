class unrealirc::config
{
  # Create config file
  $config_file = "${unrealirc::install_path}/unrealircd.conf"
  file { $config_file:
    ensure   => file,
    mode     => '0600',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    content  => template('unrealirc/unrealircd.conf.erb'),
    require  => Exec['unrealirc-dir'],
  }

  $tmp_directory = "${unrealirc::install_path}/tmp"
  file { $tmp_directory:
    ensure   => directory,
    mode     => '0777',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    require  => Exec['unrealirc-dir'],
  }

  # Create directory that will store included config files
  file { 'unrealirc_config_directory':
    path     => "${unrealirc::install_path}/config",
    ensure   => directory,
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
    require  => Exec['unrealirc-dir'],
  }

  # Define a default logger
  file { $unrealirc::log_path:
    ensure   => file,
    mode     => '0640',
    owner    => $unrealirc::user,
    group    => $unrealirc::group,
  }
}
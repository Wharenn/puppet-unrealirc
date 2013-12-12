class unrealirc::service {

  if $::osfamily == 'Debian' {

      file { '/etc/init.d/unreal':
        ensure   => file,
        mode     => '0755',
        content  => template('unrealirc/unreal.erb'),
      }

      exec { 'unrealirc_autoload':
        command => 'update-rc.d unreal defaults',
        require => File['/etc/init.d/unreal'],
      }

      service { 'unreal':
        ensure      => running,
        hasrestart  => true,
        hasstatus   => true,
        require     => File['/etc/init.d/unreal'],
      }
  }

}



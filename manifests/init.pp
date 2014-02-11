class unrealirc(
    $install_path = '/var/lib/unreal',
    $user = 'irc',
    $group = 'irc',
    $log_path = '/var/log/ircd.log',
    $servername = 'irc.myserver.org',
    $serverdesc = 'Description of irc server',
    $maxusers = 100,
    $maxservers = 10,
    $admins = ['admin <admin@myserver.org>'],
    $pidfile = '/var/lib/unreal/ircd.pid',
    $url = 'http://www.unrealircd.com/downloads/Unreal3.2.10.2.tar.gz',
    $use_ssl = false,
    $ssl_cert = undef,
    $ssl_key = undef,
    $motd = undef
) {
  class { '::unrealirc::install': } ->
  class { '::unrealirc::config': } ~>
  class { '::unrealirc::service': }
}
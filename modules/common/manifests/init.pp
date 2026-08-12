class common (
  String $package_name         = 'htop',
  String $managed_file_path    = '/tmp/puppet-managed.txt',
  String $managed_content      = "Managed by Puppet\n",
  String $managed_file_mode    = '0644',

  String $service_package_name = 'qemu-guest-agent',
  String $service_name         = 'qemu-guest-agent',
  String $managed_user         = 'puppetlab',
  String $managed_user_shell   = '/bin/bash',
) {
  package { $package_name:
    ensure => installed,
  }

  package { $service_package_name:
    ensure => installed,
  }

  service { $service_name:
    ensure  => running,
    require => Package[$service_package_name],
  }

  user { $managed_user:
    ensure     => present,
    managehome => true,
    shell      => $managed_user_shell,
  }

  file { $managed_file_path:
    ensure  => file,
    content => $managed_content,
    mode    => $managed_file_mode,
  }
}

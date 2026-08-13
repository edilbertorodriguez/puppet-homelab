class ssh_hardening (
  Boolean $permit_root_login       = false,
  Boolean $password_authentication = true,
) {
  file { '/etc/ssh/sshd_config.d/99-puppet-hardening.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp(
      'ssh_hardening/99-puppet-hardening.conf.epp',
      {
        'permit_root_login'       => $permit_root_login,
        'password_authentication' => $password_authentication,
      },
    ),
    notify  => Exec['validate-sshd-config'],
  }

  exec { 'validate-sshd-config':
    command     => '/usr/sbin/sshd -t',
    refreshonly => true,
    notify      => Service['ssh'],
  }

  service { 'ssh':
    ensure => running,
    enable => true,
  }
}

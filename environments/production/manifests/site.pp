node default {
  package { 'htop':
    ensure => installed,
  }

  file { '/tmp/puppet-managed.txt':
    ensure  => file,
    content => "Managed by Puppet\n",
    mode    => '0644',
  }
}

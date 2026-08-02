class common (
  String $package_name      = 'htop',
  String $managed_file_path = '/tmp/puppet-managed.txt',
  String $managed_content   = "Managed by Puppet\n",
  String $managed_file_mode = '0644',
) {
  package { $package_name:
    ensure => installed,
  }

  file { $managed_file_path:
    ensure  => file,
    content => $managed_content,
    mode    => $managed_file_mode,
  }
}

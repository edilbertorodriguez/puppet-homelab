node default {
  class { 'common':
    package_name      => 'htop',
    managed_file_path => '/tmp/puppet-v030.txt',
    managed_content   => "Managed by Puppet v0.3.0\n",
    managed_file_mode => '0600',
  }
}

class g10b::files {

  file { '/opt':
    ensure => directory,
    group  => 'opt',
    mode   => '0775',
    owner  => 'root',
  }

  file { '/var/lib/puppet':
    ensure => directory,
    group  => 'puppet',
    owner  => 'puppet',
  }

  file { '/etc/hiera.yaml':
    ensure => link,
    target => '/etc/puppet/hiera.yaml'
  }

  file {'/etc/pki/tls':
    ensure => directory,
  }
  file {'/etc/pki/tls/certs':
    ensure  => directory,
    require => File['/etc/pki/tls'],
  }

}
class g10b::elk(
  $kibana_port         = $g10b::elk::kibana_port,
  $kibana_user         = $g10b::elk::kibana_user,
  $kibana_group        = $g10b::elk::kibana_group,
  $elasticsearch_port  = $g10b::elk::elasticsearch_port,
  $elasticsearch_user  = $g10b::elk::elasticsearch_user,
  $elasticsearch_group = $g10b::elk::elasticsearch_group,
) {

  $config_hash = {'ES_USER' => $elasticsearch_user,'ES_GROUP' => $elasticsearch_group,}

  class {'elasticsearch':
    manage_repo           => true,
    repo_version          => '1.7',
    init_defaults         => $config_hash,
    instances_hiera_merge => true,
    plugins_hiera_merge   => true,
  }

  class {'::logstash':
    manage_repo  => true,
    repo_version => '1.5',
    require      => File ['/etc/pki/tls/private','/etc/pki/tls/certs'],
  }

  logstash::configfile {'logstash-input.conf':
    source => "puppet:///modules/${module_name}/logstash-input.conf",
    order  => 01,
  }
  logstash::configfile {'logstash-syslog.conf':
    source => "puppet:///modules/${module_name}/logstash-syslog.conf",
    order  => 50,
  }
  logstash::configfile {'logstash-apache.conf':
    source => "puppet:///modules/${module_name}/logstash-apache.conf",
    order  => 50,
  }
  logstash::configfile {'logstash-output.conf':
    source => "puppet:///modules/${module_name}/logstash-output.conf",
    order  => 99,
  }

  class {'::kibana4':
    manage_user       => true,
    kibana4_user      => $kibana_user,
    kibana4_group     => $kibana_group,
    port              => $kibana_port,
    elasticsearch_url => "http://${::fqdn}:${elasticsearch_port}",
  }
}
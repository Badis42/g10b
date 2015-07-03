class g10b::elk(
  $kibana_user        = $kibana::user,
  $kibana_group       = $kibana::group,
  $elasticsearch_port = $elasticsearch::port,
){

  class {'elasticsearch':}
  class {'logstash':
    require => Exec['logstash_add_key','logstash_add_repo'],
  }
  class {'::kibana4':
    manage_user       => true,
    kibana4_user      => $kibana_user,
    kibana4_group     => $kibana_group,
    elasticsearch_url => "http://${::fqdn}:${elasticsearch_port}",
  }
}
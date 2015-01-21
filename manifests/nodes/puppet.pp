node puppet {
	include g10b-node
	include '::mysql::server'

	$dshbrd_usr='dshbrd'
	$dshbrd_grp='dshgrp'
	$dshbrd_pwd='dshpwd'

#	class { '::mysql::server':
#		root_password => $mysql_password,
#	}

	class { 'dashboard':
		dashboard_ensure   => 'present',
		dashboard_user     => $dshbrd_usr,
		dashboard_group    => $dshbrd_grp,
		dashboard_password => $dshbrd_pwd,
		dashboard_db       => 'dashboard_prod',
		mysql_root_pw      => $mysql_password,
		dashboard_charset  => 'utf8',
        dashboard_site     => $fqdn,
        dashboard_port     => '8080',
        passenger          => true,
	}

	cron{ 'Puppet Apply':
		command => 'puppet apply $confdir/manifests --modulepath=$confdir/modules',
		user => 'puppet',
		minute => 10,
	}
}

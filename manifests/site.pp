filebucket { main: server => "puppet" }
File { backup => main }

Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

$mysql_password = "myT0pS3cretPa55worD"


node default {
  @@dns::record::a { $::hostname:
    zone => $::domain,
    data => $::ipadress,
  }
}

# ToDo: Import is deprecated
import "nodes/*.pp"
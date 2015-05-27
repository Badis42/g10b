#!/bin/bash 
set -e

if [ $UID != 0 ] ; then
	echo "Please use sudo or root account."
	exit
fi

pushd $(pwd)/$(dirname $0)
. ./install.cfg
. ./install.lib

_echo "Configuration for the ${ProjectName} project..."

_echo "Importing configuration..."
cp $(pwd)/../etc/* ${confdir}/ | tee -a ${LogFile}

_echo "Environment ${EnvName} setting..."
puppet config set environment ${EnvName}

_echo "chown -R ${DftUser}:${DftUser} ${confdir}"
chown -R ${DftUser}:${DftUser} ${confdir}

popd # pushd $(dirname $0)

_echo "Starting Puppet Client..."
#puppet resource service puppet       ensure=running enable=true
sudo puppet agent --enable
#sudo puppet agent --verbose --test --waitforcert 5
sudo puppet resource cron puppet-agent ensure=present user=root minute='*/5' command='/usr/bin/puppet agent --onetime --no-daemonize --splay'
_echo "Puppet agent scheduled."
_echo "Puppet agent configuration of server $(hostname -f) is done."
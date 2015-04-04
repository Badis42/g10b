#!/bin/bash 

if [ $UID != 0 ] ; then
	echo "Please use sudo or root account."
	exit
fi

. ./install.cfg
. ./install.lib

_apt-get --yes purge puppetmaster puppet puppetmaster-common puppet-common
_apt-get --yes purge puppetlabs-release
_apt-get --yes autoremove

grep "dir=" ${confdir}/puppet.conf | while read Line
do
	echo "rm -Rf $(echo ${Line} | awk -F"=" '{print $2}')"
	 eval rm -Rf $(echo ${Line} | awk -F"=" '{print $2}')
done

echo "rm -Rf ${confdir}"
      rm -Rf ${confdir}
#!/bin/bash 

if [ $UID != 0 ] ; then
	echo "Please use sudo or root account."
	exit
fi

pushd $(pwd)/$(dirname $0) 2>/dev/null
. ./install.cfg
. ./install.lib

while getopts "crumvb:" Option
do
	case ${Option} in
	c|C) typeset -i CleanEnv=1 ;;
    r|R) typeset -i RemoveOld=1 ;;
	u|U) typeset -i Update=1 ;;
	m|M) typeset -i ModuleUpdate=1 ;;
    v|V) typeset Verbose='v' ;;
	b|B) typeset Branch="$OPTARG" ;;
	esac
done
shift $(($OPTIND - 1))

_echo "Stopping Puppet..."
	service puppetmaster stop   | tee -a ${LogFile}
	service puppetmaster status | tee -a ${LogFile}

_echo "Puppet configuration for the ${ProjectName} project..."
pushd $(pwd)/..
if [ ${Update} ] ; then
	_echo "Update with branch ${Branch} in progress..."
	env GIT_SSL_NO_VERIFY=true git checkout ${Branch}
	env GIT_SSL_NO_VERIFY=true git pull --rebase
fi

_echo "Importing configuration..."
    _echo "Avoid the importation of the ${PrivateHiera}."
	[ -s ${PrivateHiera} ] && rm ${PrivateHiera} | tee -a ${LogFile}
	cp -R${Verbose} ./${confdir}/* /${confdir}/  | tee -a ${LogFile}
	echo "*.$(hostname -d)" > /${confdir}/autosign.conf

for EnvName in $(ls -1 ./${EnvDir}); do
	if [ ${CleanEnv} ] ; then
		_echo "Cleaning of environment ${EnvName}..."
		rm -Rf /${EnvDir}/${EnvName} | tee -a ${LogFile}
	fi
	
	_echo "Environment ${EnvName} setting..."	
		mkdir -p /${EnvDir}/${EnvName} | tee -a ${LogFile}
		cp -R${Verbose} ./${EnvDir}/${EnvName}/modules.lst /${EnvDir}/${EnvName}/ | tee -a ${LogFile}
		chown -R ${DftUser}:${DftUser} /${EnvDir}/${EnvName}
		puppet config set environment ${EnvName}
	
	if [ ${RemoveOld} ] ; then
		_echo "Removing old modules..."
			puppet module list --tree | awk -F" " '{print $2}' | grep '-' |
			while  read Module; do
				GrepResult=$(grep ${Module} ./${EnvDir}/${EnvName}/modules.lst)
				if [ $? != 0 ] ; then
					_echo "puppet module uninstall ${Module}"
					(( ! ${OffLine} )) && puppet module uninstall ${Module} | tee -a ${LogFile}
				fi
			done
	fi
	
	_echo "Adding some modules..."
		grep -v '^#' ./${EnvDir}/${EnvName}/modules.lst |
		while read Module; do
			_echo "puppet module install ${Module}"
			(( ! ${OffLine} )) && puppet module install ${Module} | tee -a ${LogFile}
			if [ ${ModuleUpdate} ] ; then
				_echo "puppet module upgrade ${Module} --ignore-dependencies"
				(( ! ${OffLine} )) && puppet module upgrade ${Module} --ignore-dependencies | tee -a ${LogFile}
			fi
		done
	
		for Thingy in modules manifests
		do
			_echo "Importing ${ProjectName} ${Thingy}..."
			mkdir -p /${EnvDir}/${EnvName}/${Thingy}/                                           | tee -a ${logfile}
			cp -R${Verbose} ./${EnvDir}/${EnvName}/${Thingy}/* /${EnvDir}/${EnvName}/${Thingy}/ | tee -a ${LogFile}
			chown -R ${DftUser}:${DftUser} /${EnvDir}/${EnvName}/${Thingy}                      | tee -a ${LogFIle}
		done
	done
	
popd # pushd $(pwd)/..
popd # pushd $(dirname $0)

_echo "puppet config set environment ${ProjectName}"
puppet config set environment ${ProjectName}

_echo "chown -R ${DftUser}:${DftUser} /${confdir}"
chown -R ${DftUser}:${DftUser} /${confdir}

_echo "Scheduling Puppet Agent..."
puppet resource cron puppet-agent ensure=present user=root minute='*/15' command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

_echo "Starting Puppet Server..."
puppet resource service puppetmaster ensure=running enable=true

_echo "puppet agent --verbose --test --waitforcert 5"
puppet agent --verbose --test --waitforcert 5

_echo "Puppet master configuration of server $(hostname -f) is done."

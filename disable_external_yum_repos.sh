#!/bin/bash
cleanup () {
	
	echo "CLeaning up and exiting"
	exit $@

}
trap cleanup SIGHUP SIGINT SIGTERM 
local='local'

#if [[ $HOME -eq '/root' ]] || { echo "Please run as root user"; cleanup 1; }

echo "Disabling all external yum repo's" 

for i in `ls /etc/yum.repos.d/`
do
	if ! [[ $i =~ $local ]]
	then
		echo "${i} is not a local repo, disabling." 
		sed -i.bak 's/enabled=1/enabled=0/' /etc/yum.repos.d/$i
  	else
    		echo "${i} is a local repo, keeping enabled."
	fi
done


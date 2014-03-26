#!/bin/bash
# Run me from the $USER_PATH/projects dir to kill vagrant instances in sub dirs

for i in `ls`
do
	cd $i
	if [ -f Vagrantfile ]
	then
		echo "FOUND VAGRANT FILE **********************************************************"
		echo "Killing vagrant in $i"
		vagrant destroy -f
		echo "vagrant destroyed..."
		cd /Users/malnick/projects
	else
		echo "Vagrant File not found in $i"
		cd /Users/malnick/projects
	fi
done


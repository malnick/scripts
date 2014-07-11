#!/bin/bash
VPNENV=`echo $(naclient status | awk 'NR==4' | cut -d: -f2)`
MYENV='d4p4'
if [ $VPNENV == $MYENV ]
then
	echo "Connecting to jumphost:"
	ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/jump.sock' -N -f -L 5000:172.24.3.12:22 root@172.20.132.3
	echo "Connecting yum repo:"
	ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/yum.sock' -o 'UserKnownHostsFile /dev/null' -N -f root@localhost -p 5000

	read -p "Would you like to transfer a file now ([no] will still create a persistant socket for use in transferring later)? " transfer 
	if [[ $transfer =~ ^y ]] 
	then
		echo "What is the path to the file you're transferring?" 
		read filepath

		scp -o 'ControlPath ~/.ssh/yum.sock' -P 5000 $filepath root@localhost:/tmp/ 
	else
		echo "If you wish to transfer a file later you can run:"
		echo "scp -o 'ControlPath ~/.ssh/yum.sock' -P 5000 $local_filepath root@localhost:$remote_filepath"
	fi
	echo "----"
	echo "A persistant socket to yum repo in integration has been created."
	echo "To connect to this socket:" 
	echo "ssh -S ~/.ssh/yum.sock root@localhost -p 5000" 
	echo "----"
	echo "To destroy sockets:"
	echo "./destroy_yum_sockets"
	echo "----"
	echo "If destroy script is not present, destroy with:"
	echo "ssh -S ~/.ssh/yum.sock -O exit root@localhost"
	echo "ssh -S ~/.ssh/jump.sock -O exit root@172.20.132.3"
fi

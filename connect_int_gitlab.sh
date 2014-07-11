#!/bin/bash
VPNENV=`echo $(naclient status | awk 'NR==4' | cut -d: -f2)`
VPN="d4p4"
[ "${VPNENV}" == "${VPN}" ] || { echo "Connect VPN to d4p4"; echo "Currently connected to $VPN"; exit 1; }

getport(){
	PORT=$(( $RANDOM % 1000 + 5000 ))
	CHECK=$(netstat -an |grep LISTEN | egrep "[.:]${PORT}\s" > /dev/null; echo $?) 
	while [[ "$CHECK" == 0 ]]
	do
		echo "Port: $PORT is in use by another process, choosing another port." 
		PORT=$(( $RANDOM % 1000 + port ))
		CHECK=$(netstat -an |grep LISTEN | egrep "[.:]$PORT\s" > /dev/null; echo $?) 
	done
	echo "Setting port to $PORT"
}
getport

echo "Connecting to jumphost:"
ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/jump.sock' -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' -N -f -L $PORT:172.24.3.246:22 root@172.20.132.3
echo "Connecting gitlab repo:"
ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/intgit.sock' -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' -N -f root@localhost -p $PORT



echo "----"
echo "A persistant socket to gitlab in integration has been created."
echo "To connect to this socket:" 
echo "ssh -S ~/.ssh/intgit.sock root@localhost -p $PORT" 
echo "----"
echo "To destroy sockets:"
echo "./destroy_intgit_sockets"
echo "----"
echo "If destroy script is not present, destroy with:"
echo "ssh -S ~/.ssh/intgit.sock -O exit root@localhost"
echo "ssh -S ~/.ssh/jump.sock -O exit root@172.20.132.3"

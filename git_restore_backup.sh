#!/bin/bash

# Ensure vpn is up
VPNENV=`echo $(naclient status | awk 'NR==4' | cut -d: -f2)`
DALLAS="d4p4"
LABGIT="10.144.36.226"
INTGIT="172.24.3.246"
JUMPHOST="172.20.132.3"
MYHOST=$(ifconfig en4 | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | cut -d: -f 2 | cut -d' ' -f2) # Your mileage will definetely vary 
MYUSER="malnick"
SSHTO="${MYUSER}@${MYHOST}"

# Logic 
if [ "$VPNENV" == "$DALLAS" ]
then
	echo "Connected to $VPNENV" 

	# SSH Lab-Git and run rake backup
	ssh -l root $LABGIT gitlab-rake gitlab:backup:create && exit
	ssh -l root $LABGIT rm /tmp/backup.tar
	ssh -l root $LABGIT ln -s $(ls -t /var/opt/gitlab/backups/ |head -1) /tmp/backup.tar
	scp root@$LABGIT:/tmp/backup.tar /tmp/backup.tar

	# SCP backup to INT-Git
	( 
		ssh -C -N -L 5000:172.24.3.246:22 root@172.20.132.3 &
	)
	SSHPID=$!


	# SSH INT-Git and run rake restore on new database
	#ssh -A -t -l root $JUMPHOST \ ssh -A -t -l root $INTGIT run rake restore

else
	echo "VPN Connection to $(VPNENV)"
	echo "This is not d4p4, bailing"
	exit 1
fi


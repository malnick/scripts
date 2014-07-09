#!/bin/bash
# Author: Jeff Malnick

test -e ~/.ssh || { echo "Create an ssh dir"; exit 1; }

VPNENV=`echo $(naclient status | awk 'NR==4' | cut -d: -f2)`
DALLAS="a1b2" #VPN Gateway 
LABGIT="10.0.1.2" #Local git repo
INTGIT="172.24.3.246" #Integration git repo behind jumphost
JUMPHOST="172.20.100.3" #Jumphost

stagelatest(){
	LATESTBAK=$(ls -t /var/opt/gitlab/backups/ | head -1)
	rm /tmp/1111111111_gitlab_backup.tar
	ln -s /var/opt/gitlab/backups/$LATESTBAK /tmp/1111111111_gitlab_backup.tar
}

if [ "$VPNENV" == "$DALLAS" ]
then
	echo "Connected to $VPNENV"

	echo "Connecting to git in labs:"
	ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/labgit.sock' -N -f root@$LABGIT 
	echo "Connecting to jumphost:"
	ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/jump.sock' -N -f -L 5000:$INTGIT:22 root@$JUMPHOST
	echo "Connecting to git in integration:"
	ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/intgit.sock' -N -f root@localhost -p 5000

	# SSH labgit and run rake backup, scp to latest backup to host 
	echo "Running gitlab:backup:create"
	ssh -S ~/.ssh/labgit.sock root@$LABGIT gitlab-rake gitlab:backup:create
	echo "Staging backup in /tmp"
	ssh -S ~/.ssh/labgit.sock root@$LABGIT "$(typeset -f); stagelatest"
	echo "Copying over from lab git to localhost"
	scp -o 'ControlPath ~/.ssh/labgit.sock' root@$LABGIT:/tmp/1111111111_gitlab_backup.tar /tmp/
	echo "Copying lab git backup from localhost to integration git server"
	scp -o 'ControlPath ~/.ssh/intgit.sock' -P 5000 /tmp/1111111111_gitlab_backup.tar root@localhost:/var/opt/gitlab/backups
	echo "Running restore on integration git server"
	ssh -S ~/.ssh/intgit.sock root@localhost -p 5000 BACKUP=1111111111_gitlab_backup.tar gitlab-rake gitlab:backup:restore
	echo "Complete"
else

	echo "VPN Enviro not correct, connected to $VPNENV" 
	echo "Check VPN connection to d4p4, or start NA Client"
	exit 1

fi

ssh -S ~/.ssh/labgit.sock -O exit root@$GITLAB
ssh -S ~/.ssh/intgit.sock -O exit root@localhost
ssh -S ~/.ssh/jump.sock -O exit root@$JUMPHOST


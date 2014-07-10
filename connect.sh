#!/bin/bash
cleanup () {
	test -e ~/.ssh/labgit.sock && ssh -S ~/.ssh/labgit.sock -O exit root@$GITLAB
	test -e ~/.ssh/intgit.sock && ssh -S ~/.ssh/intgit.sock -O exit root@localhost
	test -e ~/.ssh/jump.sock && ssh -S ~/.ssh/jump.sock -O exit root@$JUMPHOST
	exit $@
}
trap cleanup SIGHUP SIGINT SIGTERM

stagelatest () {
	LATESTBAK=$(ls -t /var/opt/gitlab/backups/ | head -1)
	rm /tmp/1111111111_gitlab_backup.tar
	ln -s /var/opt/gitlab/backups/$LATESTBAK /tmp/1111111111_gitlab_backup.tar
}

test -e ~/.ssh || { echo "Create an ssh dir"; exit 1; }

VPNENV=`echo $(naclient status | awk 'NR==4' | cut -d: -f2)`
DALLAS="YourVPNGatewayName"
LABGIT="10.10.1.100" # A Local Git Server
INTGIT="172.24.1.200" # A Corralled Integration Git Server 
JUMPHOST="172.20.2.3" # Jump Host to Integration Git Server

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
	echo "Would you like to run restore on the integration server now?" 
	read restore 
	if [[ "$restore" == "yes" || "y" || "Y" || "Yes" ]]
	then
		echo "Running restore on integration git server"
		ssh -S ~/.ssh/intgit.sock root@localhost -p 5000 BACKUP=1111111111_gitlab_backup.tar gitlab-rake gitlab:backup:restore
	else
		echo "Not running restore" 
		echo "Backup located at /var/opt/gitlab/backups/1111111111_gitlab_backup.tar"
		echo "-----"
		echo "To backup manually run:"
		echo "BACKUP=1111111111_gitlab_backup.tar gitlab-rake gitlab:backup:restore"
	fi
	cleanup 
else

	echo "VPN Enviro not correct, connected to $VPNENV" 
	echo "Check VPN connection to d4p4, or start NA Client"
	cleanup 1
fi



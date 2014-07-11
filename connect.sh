#!/bin/bash
cleanup () {
	echo "Cleaning up sockets and exiting"
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

getport () {
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

test -e ~/.ssh || { echo "Create an ssh dir"; exit 1; }

VPNENV=`echo $(naclient status | awk 'NR==4' | cut -d: -f2)`
DALLAS="d4p4"
LABGIT="10.144.36.226"
INTGIT="172.24.3.246"
JUMPHOST="172.20.132.3"

if [ "$VPNENV" == "$DALLAS" ]
then
	echo "Connected to $VPNENV"

	echo "Connecting to git in labs:"
	ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/labgit.sock' -N -f root@$LABGIT 
	echo "Connecting to jumphost:"
	ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/jump.sock' -N -f -L $PORT:$INTGIT:22 root@$JUMPHOST
	echo "Connecting to git in integration:"
	ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/intgit.sock' -o 'UserKnownHostsFile /dev/null' -N -f root@localhost -p $PORT

	# SSH labgit and run rake backup, scp latest backup to host 
	echo "Running gitlab:backup:create"
	ssh -S ~/.ssh/labgit.sock root@$LABGIT gitlab-rake gitlab:backup:create
	echo "Staging backup in /tmp"
	ssh -S ~/.ssh/labgit.sock root@$LABGIT "$(typeset -f); stagelatest"
	echo "Copying over from lab git to localhost"
	scp -o 'ControlPath ~/.ssh/labgit.sock' root@$LABGIT:/tmp/1111111111_gitlab_backup.tar /tmp/
	echo "Copying lab git backup from localhost to integration git server"
	scp -o 'ControlPath ~/.ssh/intgit.sock' -P $PORT /tmp/1111111111_gitlab_backup.tar root@localhost:/var/opt/gitlab/backups
	echo "Would you like to run restore on the integration server now?" 
	read restore 
	if [[ $restore =~ ^y ]]
	then
		echo "Running restore on integration git server"
		ssh -S ~/.ssh/intgit.sock root@localhost -p $PORT BACKUP=1111111111 gitlab-rake gitlab:backup:restore <<< yes
	else
		echo "Not running restore" 
		echo "Backup located at /var/opt/gitlab/backups/1111111111_gitlab_backup.tar"
		echo "-----"
		echo "To backup manually run:"
		echo "BACKUP=1111111111_gitlab_backup.tar gitlab-rake gitlab:backup:restore"
	fi
	cleanup 
else

	echo "VPN Enviro not correct, connected to: $VPNENV" 
	echo "Check VPN connection to d4p4, or start NA Client"
	cleanup 1
fi



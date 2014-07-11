#!/bin/bash
MYENV='d4p4'

[ -z "$1" ] && { echo "please pass some rpms to upload"; exit 1; }


VPNENV=`echo $(naclient status | grep "Remote Network" | cut -d: -f2 | awk '{print $1}')`
[ "${VPNENV}" != "${MYENV}" ] && { echo "please connect to d4p4 vpn"; exit 1; }

echo "Connecting to jumphost:"
ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/jump.sock' -N -f -L 5000:172.24.3.12:22 172.20.132.3 || { echo "failed to connect to jump host"; exit 1; }

echo "Connecting yum repo:"
ssh -o 'ControlMaster auto' -o 'ControlPath ~/.ssh/yum.sock' -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' \
  -N -f root@localhost -p 5000 || { echo "failed to connect to yum host"; exit 1; }


for f in $@; do
  echo "Copying $f"
  scp -o 'ControlPath ~/.ssh/yum.sock' -P 5000 $f root@localhost:/var/www/html/vchs/
done

echo "updating repo"
ssh -o 'ControlPath ~/.ssh/yum.sock' -p 5000 root@localhost 'cd /var/www/html/vchs/; /usr/bin/createrepo .'

echo "updating selinux tags"
ssh -o 'ControlPath ~/.ssh/yum.sock' -p 5000 root@localhost 'chcon -R -t httpd_sys_content_t /var/www/html/'
ssh -o 'ControlPath ~/.ssh/yum.sock' -p 5000 root@localhost 'chcon -R -t httpd_sys_content_t /var/www/html/vchs/'

echo "Closing yum repo connection"
ssh -S ~/.ssh/yum.sock -O exit root@localhost
echo "Closing jump host connection"
ssh -S ~/.ssh/jump.sock -O exit root@172.20.132.3

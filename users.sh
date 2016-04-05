#/bin/bash
declare -a HOSTS
declare -a USERS

USERS=('sam' 'joe' 'bob' 'sally' 'eve' 'jenn' 'flo' 'tobi' 'tyler' 'sargun' 'seb' 'cody' 'jeremy' 'jesse')
HOSTS=(52.38.10.229 52.27.149.70 52.36.206.9 52.25.9.34 52.36.220.149)

getuid () {
  ID=$(( $RANDOM % 2000 + 5000 ))
}

for h in ${HOSTS[@]}
do
  for u in ${USERS[@]}
  do
    getuid
    echo "Setting host $h with user $u with id $ID"
    ssh -i ~/.ssh/mesos_dev.pem centos@$h useradd $u -u $ID
  done
done

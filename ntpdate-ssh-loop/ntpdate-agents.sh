#!/bin/sh
# Requires nmap (brew install nmap)


echo "Discovering shit..."
nmap -sP 10.0.20.1-255 > agents.txt 

for line in $(cat agents.txt)
do 
	echo "$line" | grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" >> hosts.txt
done < /dev/null

echo "Shit found:"
cat hosts.txt
echo "***"

if [ -f hosts.txt ]
then
	echo "Get ready to type.... a lot .... "
	for host in $(cat hosts.txt)
	do
		cat /Users/malnick/.ssh/id_rsa.pub | ssh root@"$host" 'cat >> .ssh/authorized_keys'
	done
	
	echo "Done typing!"
	echo "Running ntpdate on this shit..." 
	# replace with read line and $line for compiled list in a file
	for i in $(cat hosts.txt)
	do
		ssh root@"$i" "ntpdate us.pool.ntp.org" 
	done
	echo "Over this shit, later."
else 
	echo "What kind of shit is this? hosts.txt not found"
fi
 

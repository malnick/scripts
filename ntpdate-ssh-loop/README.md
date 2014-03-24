### mCollective Egg Problem

I wanted to get specific state info about the pe-httpd service from all nodes in classroom. 

	mco rpc service status service=pe-httpd

my output was sparce, considering a class of 15:

	peadmin@malnick:/root$ mco rpc service status service=pe-httpd
	Discovering hosts using the mc method for 2 second(s) .... 3

 	* [ ============================================================> ] 3 / 3


	gonzo.puppetlabs.vm
   	Service Status: running

	malnick.puppetlabs.vm
   	Service Status: running

	raja.puppetlabs.vm
   	Service Status: running


	Summary of Service Status:

   	running = 3


	Finished processing 3 / 3 hosts in 352.63 ms

So I wrote this stupid shell scirpt to run ntpdate on any classroom enviro, get the hosts on the subnet using nmap, then passing my ssh key into the hosts authorized_keys - yeah, it requires a lot of 'yes' followed by 'puppet' but once that's golden it ssh's each machine and runs ntpdate.

After running my script:


	rpc service status service=pe-httpd
	Discovering hosts using the mc method for 2 second(s) .... 14

 	* [ ============================================================> ] 14 / 14

I got 14 instead of the previous 3 agents running pe-httpd, meaning that mcollective can make the connection to the agetns since time was updated. 

Go ahead, unload, it's stupid fucking shell script hack. 

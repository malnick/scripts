# Random MCO stuff

mco -F osfamily=/^R/ # CASE SENSITIVE

mco -F virtual=vmware

mco facts virtual -v 

mco -C # for discovering classes

mco inventory malnick.puppetlabs.vm # get a bunch of inventory stuff

# var/opt/lib/pe-puppet has resources.txt and has a list of all resources managemed by puppet on that system

mco package status httpd

mco package status httpd -F hostname=/^m/

mco status

mco puppet disable # disable puppet on all machines

mco puppet enable

mco puppet runall 3 # discovers all nodes, and triggers puppet run on 3 at a time




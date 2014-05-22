#!/bin/bash
# Get a node catalogue with the psudo RESTful Puppet API
# This runs out of the box on the master for the master, augment node certname in string as needed

curl --cert $(puppet config print ssldir)/certs/$(facter fqdn).pem --key $(puppet config print ssldir)/private_keys/$(facter fqdn).pem --cacert $(puppet config print ssldir)/ca/ca_crt.pem -H 'Accept: pson' https://master.puppetlabs.vm:8140/production/catalog/master.puppetlabs.vm > master_catalogue.json

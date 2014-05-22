#!/bin/bash
# Get a node catalogue with the psudo RESTful Puppet API

curl --cert /etc/puppetlabs/puppet/ssl/certs/master.puppetlabs.vm.pem --key /etc/puppetlabs/puppet/ssl/private_keys/master.puppetlabs.vm.pem --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem -H 'Accept: pson' https://master.puppetlabs.vm:8140/production/catalog/master.puppetlabs.vm > master_catalogue.json

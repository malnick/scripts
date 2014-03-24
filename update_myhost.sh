#!/bin/bash
echo "$(ifconfig eth0 | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | cut -d: -f 2 | cut -d' ' -f 1) master.puppetlabs.vm master" >> /etc/hosts

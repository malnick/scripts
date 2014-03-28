#!/bin/sh
 
sudo /opt/puppet/bin/bundle exec rake -f /opt/puppet/share/console-auth/Rakefile db:create_user USERNAME="malnick" PASSWORD="shd123" ROLE="Admin"


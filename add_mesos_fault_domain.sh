#!/bin/bash
# Automatically configure mesos fault domains. 
# To run:
#    bash add_mesos_fault_domain.sh <role:slave|master>
# Author: github.com/malnick

ROLE=$1
MESOS_COMMON="/opt/mesosphere/etc/mesos-${ROLE}"
REGION=`curl -s 169.254.169.254/latest/dynamic/instance-identity/document/ | grep region | cut -d "\"" -f4`
AZ=`curl -s 169.254.169.254/latest/meta-data/placement/availability-zone`

cat > /etc/mesosphere/fault-domains.json <<-EOF
{
  "fault_domain": {
    "region": {
      "name": "${REGION}"
    },
    "zone": {
      "name": "${AZ}"
    }
  }
}
EOF

cp $MESOS_COMMON $MESOS_COMMON.bk
echo 'MESOS_DOMAIN=file:///etc/mesosphere/fault-domains.json' >> $MESOS_COMMON
systemctl restart dcos-mesos-$ROLE

#!/bin/sh


keystone user-create --name neutron --pass {{ pillar["neutron_passwd"] }}
keystone user-role-add --user neutron --tenant service --role admin

keystone service-create --name neutron --type network \
  --description "OpenStack Networking"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ network / {print $2}') \
  --publicurl http://controller:9696 \
  --adminurl http://controller:9696 \
  --internalurl http://controller:9696 \
  --region regionOne

#!/bin/sh

keystone user-create --name glance --pass {{ pillar["glance_passwd"] }}
keystone user-role-add --user glance --tenant service --role admin

keystone service-create --name glance --type image \
  --description "OpenStack Image Service"

keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ image / {print $2}') \
  --publicurl http://controller:9292 \
  --internalurl http://controller:9292 \
  --adminurl http://controller:9292 \
  --region regionOne

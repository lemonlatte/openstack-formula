#!/bin/sh

keystone user-create --name nova --pass {{ pillar["nova_passwd"] }}
keystone user-role-add --user nova --tenant service --role admin

keystone service-create --name nova --type compute --description "OpenStack Compute"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ compute / {print $2}') \
  --publicurl http://controller:8774/v2/%\(tenant_id\)s \
  --internalurl http://controller:8774/v2/%\(tenant_id\)s \
  --adminurl http://controller:8774/v2/%\(tenant_id\)s \
  --region regionOne

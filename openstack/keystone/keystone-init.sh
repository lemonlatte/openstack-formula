#!/bin/sh

COUNTER=5
nc -w1 controller 5000
while [ $? -ne 0 ] && [ $COUNTER -gt 0 ]; do
    let COUNTER=COUNTER-1
    sleep 3
    nc -w1 controller 5000
done

keystone tenant-create --name admin --description "Admin Tenant"
keystone user-create --name admin --pass {{ pillar["admin_passwd"] }}
keystone role-create --name admin
keystone user-role-add --tenant admin --user admin --role admin
keystone role-create --name _member_
keystone user-role-add --tenant admin --user admin --role _member_
keystone tenant-create --name demo --description "Demo Tenant"
keystone user-create --name demo --pass {{ pillar["admin_passwd"] }} --email EMAIL_ADDRESS
keystone user-role-add --tenant demo --user demo --role _member_
keystone tenant-create --name service --description "Service Tenant"
keystone service-create --name keystone --type identity   --description "OpenStack Identity"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ identity / {print $2}') \
  --publicurl http://controller:5000/v3 \
  --internalurl http://controller:5000/v3 \
  --adminurl http://controller:35357/v3 --region regionOne

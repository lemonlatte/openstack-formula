#!/bin/sh

COUNTER=5
nc -w1 controller 5000
while [ $? -ne 0 ] && [ $COUNTER -gt 0 ]; do
    let COUNTER=COUNTER-1
    sleep 3
    nc -w1 controller 5000
done

/usr/local/bin/openstack user create --password={{pillar["admin_passwd"]}} --email={{pillar["admin_email"]}} admin
/usr/local/bin/openstack role create admin
/usr/local/bin/openstack project create --description="Admin Tenant" admin
/usr/local/bin/openstack role add --user=admin --project=admin admin

/usr/local/bin/openstack user create --password={{pillar["admin_passwd"]}} --email={{pillar["admin_email"]}} demo
/usr/local/bin/openstack role create __member__
/usr/local/bin/openstack project create --description="demo Tenant" demo
/usr/local/bin/openstack role add --user=admin --project=demo __member__
/usr/local/bin/openstack role add --user=demo --project=demo __member__

/usr/local/bin/openstack project create --description="Service Tenant" service

/usr/local/bin/openstack service create --name=keystone identity

/usr/local/bin/openstack endpoint create identity public http://controller:5000/v3
/usr/local/bin/openstack endpoint create identity internal http://controller:5000/v3
/usr/local/bin/openstack endpoint create identity admin http://controller:35357/v3

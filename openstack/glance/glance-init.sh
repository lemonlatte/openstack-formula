#!/bin/sh

/usr/local/bin/openstack user create --password={{ pillar["glance_passwd"] }} glance
/usr/local/bin/openstack role add --user=glance --project=service admin

if ! /usr/local/bin/openstack service show image; then
    # Add Service
    /usr/local/bin/openstack service create --name=glance image
    # Add Endpoints
    /usr/local/bin/openstack endpoint create image public http://controller:9292
    /usr/local/bin/openstack endpoint create image internal http://controller:9292
    /usr/local/bin/openstack endpoint create image admin http://controller:9292
fi

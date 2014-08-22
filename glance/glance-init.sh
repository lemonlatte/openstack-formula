#!/bin/sh

/usr/local/bin/openstack user create --password={{ pillar["glance_passwd"] }} glance
/usr/local/bin/openstack role add --user=glance --project=service admin

/usr/local/bin/openstack service create --name=glance image

/usr/local/bin/openstack endpoint create image public http://controller:9292
/usr/local/bin/openstack endpoint create image internal http://controller:9292
/usr/local/bin/openstack endpoint create image admin http://controller:9292

#!/bin/sh

/usr/local/bin/openstack user create --password={{ pillar["neutron_passwd"] }} neutron
/usr/local/bin/openstack role add --user=neutron --project=service admin

/usr/local/bin/openstack service create --name=neutron network

/usr/local/bin/openstack endpoint create network public http://controller:9696
/usr/local/bin/openstack endpoint create network internal http://controller:9696
/usr/local/bin/openstack endpoint create network admin http://controller:9696

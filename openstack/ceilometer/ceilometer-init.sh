#!/bin/sh

/usr/local/bin/openstack user create --password={{ pillar["ceilometer_passwd"] }} ceilometer
/usr/local/bin/openstack role create ResellerAdmin
/usr/local/bin/openstack role add --user=ceilometer --project=service ResellerAdmin

#!/bin/sh

/usr/local/bin/openstack user create --password={{ pillar["cinder_passwd"] }} cinder
/usr/local/bin/openstack role add --user=cinder --project=service admin

if ! /usr/local/bin/openstack service show volume; then
    # Add Service
    /usr/local/bin/openstack service create --name=cinder volume
    # Add Endpoints
    /usr/local/bin/openstack endpoint create volume public http://controller:8776/v1/%\(tenant_id\)s
    /usr/local/bin/openstack endpoint create volume internal http://controller:8776/v1/%\(tenant_id\)s
    /usr/local/bin/openstack endpoint create volume admin http://controller:8776/v1/%\(tenant_id\)s
fi

if ! /usr/local/bin/openstack service show volumev2; then
    # Add Service
    /usr/local/bin/openstack service create --name=cinderv2 volumev2
    # Add Endpoints
    /usr/local/bin/openstack endpoint create volumev2 public http://controller:8776/v2/%\(tenant_id\)s
    /usr/local/bin/openstack endpoint create volumev2 internal http://controller:8776/v2/%\(tenant_id\)s
    /usr/local/bin/openstack endpoint create volumev2 admin http://controller:8776/v2/%\(tenant_id\)s
fi

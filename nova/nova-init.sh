#!/bin/sh

/usr/local/bin/openstack user create --password={{ pillar["nova_passwd"] }} nova
/usr/local/bin/openstack role add --user=nova --project=service admin

if ! /usr/local/bin/openstack service show compute; then
    # Add Service
    /usr/local/bin/openstack service create --name=nova compute
    # Add Endpoints
    /usr/local/bin/openstack endpoint create compute public http://controller:8774/v2/%\(tenant_id\)s
    /usr/local/bin/openstack endpoint create compute internal http://controller:8774/v2/%\(tenant_id\)s
    /usr/local/bin/openstack endpoint create compute admin http://controller:8774/v2/%\(tenant_id\)s
fi

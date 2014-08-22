#!/bin/sh

# Configure the bridge for internal communication
ovs-vsctl add-br br-int
# Configure the bridge for external communication
ovs-vsctl add-br br-ex
# ovs-vsctl set bridge br-ex stp_enable=true
# Enable external network access under nested Open vSwitch
ifconfig br-ex promisc up
# Bind em1 to the external bridge
ovs-vsctl add-port br-ex em1
# Get ip address from dhcp server
dhclient br-ex
# clean ip of em1
ifconfig em1 0.0.0.0

#!/bin/sh


# Configure the bridge for internal communication
ovs-vsctl add-br br-int
# Configure the bridge for external communication
ovs-vsctl add-br br-ex
# ovs-vsctl set bridge br-ex stp_enable=true
# Enable external network access under nested Open vSwitch
ifconfig br-ex promisc up
# Bind eth2 to the external bridge
ovs-vsctl add-port br-ex eth0

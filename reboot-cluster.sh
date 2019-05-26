#!/bin/bash -e

# Default values

dc_name="lab"
cluster_name="nuc"

#TODO take some args for DC and Cluster names
cluster_path="/$dc_name/host/$cluster_name"

for host in `govc find $cluster_path -type h`; do

#TODO check to make sure that no hosts are in maintenance mode

#enter maintenance mode
  govc host.maintenance.enter $host

#TODO verify that the host is in maintenance mode

#shutdown the host
#govc host.shutdown -r=true -host.ip=192.168.10.85
  govc host.shutdown -r=true $host
#wait for host to report as unresponsive to vCenter
  sleep 300
#wait for the host to come back online in vCenter

#exit from maintenance mode
#govc host.maintenance.exit -host.ip=192.168.10.85
  govc host.maintenance.exit $host
done
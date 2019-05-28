#!/bin/bash -e

# Default values
dc_name="lab"
cluster_name="nuc"

#TODO take some args for DC and Cluster names
cluster_path="/$dc_name/host/$cluster_name"

for host in `govc find $cluster_path -type h`; do
#enter maintenance mode
  echo "Placing $host in maintenance mode"
  govc host.maintenance.enter $host
#shutdown the host
  echo "Restarting $host"
  govc host.shutdown -r=true $host
#wait for host to report as unresponsive to vCenter
  conn_state=$(govc object.collect -json $host | jq -r '.[28] .Val .ConnectionState')
  while [ $conn_state != "notResponding" ]; do
    echo "Waiting for the esxi host $host to stop responding to vCenter - sleeping for 10s"
    sleep 10
    conn_state=$(govc object.collect -json $host | jq -r '.[28] .Val .ConnectionState')
  done
  echo "exited the loop"
#wait for the host to come back online in vCenter
  while [ $conn_state != "connected" ]; do
    echo "Waiting for the esxi host $host to come back online in vCenter - sleeping for 10s"
    sleep 10
    conn_state=$(govc object.collect -json $host | jq -r '.[28] .Val .ConnectionState')
  done
#exit from maintenance mode
  echo "Exiting $host from maintenance mode"
  govc host.maintenance.exit $host
done
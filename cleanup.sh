#!/usr/bin/env bash

display_usage() {
    echo "Usage:"
    echo "./cleanup.sh machine_name"
    echo "  machine_name: the name of the docker machine where the rancher-nginx container is running"
} 

if [ $# -ne 1 ]; then
    display_usage
    exit 1
fi

MACHINE=$1

sudo sed -i '' '/.*RANCHER_SCRIPT_ADD$/d' /etc/hosts
docker-machine ssh $MACHINE "sudo sed -i '/.*RANCHER_SCRIPT_ADD$/d' /etc/hosts"
docker-machine active $MACHINE
docker $(docker-machine config $MACHINE) rm -vf rancher-nginx

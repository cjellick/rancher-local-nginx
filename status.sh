#!/usr/bin/env bash

display_usage() {
    echo "Usage:"
    echo "./status.sh machine_name"
    echo "  machine_name: the name of the docker machine where the rancher-nginx container is running"
} 

if [ $# -ne 1 ]; then
    display_usage
    exit 1
fi

MACHINE=$1

echo "Local host entries:"
grep RANCHER_SCRIPT_ADD /etc/hosts

echo "Machine host entries:"
docker-machine ssh $MACHINE grep RANCHER_SCRIPT_ADD /etc/hosts

echo "rancher-nginx containers:"
docker $(docker-machine config $MACHINE) ps -a | grep rancher-nginx

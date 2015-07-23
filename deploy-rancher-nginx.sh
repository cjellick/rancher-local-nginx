#!/usr/bin/env bash

display_usage() {
    echo -e "Usage:"
    echo -e "deploy-ngnix desired_hostname docker_machine" 
    #echo "  ip-of-vm:         IP of the VM where the nginx container will be deployed, ie: docker-machine ip <name of machine>"
    echo "  desired-hostname: Hostname through which you want to access Rancher."
    echo "  docker_machine:   Name of the docker-machine vm where the container will be deployed."
}

if [ $# -lt 2 ]; then
    display_usage
    exit 1
fi

MACHINE=$2
IP="$(docker-machine ip $MACHINE)"
HOSTNAME=$1

# Backup /etc/hosts
sudo cp /etc/hosts /etc/hosts.backup

# Configure host entry on laptop
echo "$IP $HOSTNAME # RANCHER_SCRIPT_ADD" | sudo tee -a /etc/hosts > /dev/null

# Configure host entry inside of docker machine
docker run --rm --privileged -v /etc/hosts:/machine/etc/hosts cjellick/update-host-entry:v0.1.0 $IP $HOSTNAME

# Write nginx conf to appropriate place
./write-nginx-config.sh $HOSTNAME

# Start nginx container
docker rm -fv rancher-nginx 2>/dev/null
docker run --name rancher-nginx -p 80:80 -v $(pwd)/conf/nginx.rancher.local.conf:/etc/nginx/nginx.conf:ro -d nginx

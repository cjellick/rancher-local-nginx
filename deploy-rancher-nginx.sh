#!/usr/bin/env bash

display_usage() {
    echo "Usage:"
    echo "deploy-ngnix [-x] desired_hostname docker_machine"
    echo "  -x:               Flag indicating X-Forwarded-{Proto,Host} should be used in nginx config instead of X-API-request-url"
    echo "  desired-hostname: Hostname through which you want to access Rancher."
    echo "  docker_machine:   Name of the docker machine where the container will be deployed."
}

if [ $# -lt 2 ]; then
    display_usage
    exit 1
fi

USE_X_FORWARDED="false"
for key in "$@"; do
    if [ $key = '-x' ]; then
        USE_X_FORWARDED=true
        shift
    fi
done

MACHINE=$2
IP="$(docker-machine ip $MACHINE)"
HOSTNAME=$1

# Write nginx conf to appropriate place
./write-nginx-config.sh $HOSTNAME $USE_X_FORWARDED

# Backup /etc/hosts
sudo cp /etc/hosts /etc/hosts.backup

# Configure host entry on laptop
echo "$IP $HOSTNAME # RANCHER_SCRIPT_ADD" | sudo tee -a /etc/hosts > /dev/null

# Configure host entry inside of docker machine
docker run --rm --privileged -v /etc/hosts:/machine/etc/hosts cjellick/update-host-entry:v0.1.0 $IP $HOSTNAME

# Start nginx container
docker rm -fv rancher-nginx 2>/dev/null
docker $(docker-machine config $MACHINE) run --name rancher-nginx -p 80:80 -v $(pwd)/conf/nginx.rancher.local.conf:/etc/nginx/nginx.conf:ro -d nginx

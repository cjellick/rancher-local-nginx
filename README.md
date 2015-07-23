# rancher-local-nginx

A simple script that will setup your local development rancher environment to run behind an nginx proxy.

Usage:
```
deploy-ngnix desired_hostname docker_machine
  desired_hostname: Hostname through which you want to access Rancher.
  docker_machine:   Name of the docker-machine vm where the container will be deployed.
```

Once you run that, you'll be able to access rancher at `http://desired_hostname/v1`, as will your rancher-agent container.

Assumes:
* You're using docker-machine.
* You're on a Mac.

What it does:

1. Sets up appropriate entries in your Mac's and you docker machine's /etc/hosts to point $HOSTNAME at the IP of your docker machine
1. Writes a basic nginx config that will proxy requests on port 80 to 10.0.2.2:8080 (Default Gateway on VirtualBox Vms)
1. Starts an nginx container listening on host port 80 of your docker machine

Note that for this to work end-to-end, you'll also need to set the cattle property `api.allow.client.override=true`.


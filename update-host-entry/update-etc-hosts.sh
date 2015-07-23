#!/bin/sh

cp /etc/hosts /etc/hosts.backup
echo "$1 $2 # RANCHER_SCRIPT_ADD" | tee -a /machine/etc/hosts > /dev/null

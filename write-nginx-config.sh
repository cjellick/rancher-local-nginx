#!/usr/bin/env bash

HOSTNAME=$1

mkdir -p conf

cat >conf/nginx.rancher.local.conf <<EOL
user www-data;
worker_processes 4;
pid /run/nginx.pid;

events {
	worker_connections 768;
}

http {
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;


	include /etc/nginx/mime.types;
	default_type application/octet-stream;


	access_log /dev/stdout;
	error_log /dev/stderr;


	gzip on;
	gzip_disable "msie6";

    upstream rancher {
        server 10.0.2.2:8080;
    }

    server {
        listen 80;
        server_name proxy_server;

        location / {
            proxy_set_header X-API-request-url \$scheme://$HOSTNAME\$request_uri;
            proxy_pass http://rancher;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
EOL


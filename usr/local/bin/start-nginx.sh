#!/bin/sh -e

echo "Preparing Nginx configuration"
confd -onetime -backend env -log-level debug

if [ -d "/var/nginx/conf.d" ]; then
  echo "Using custom Nginx conf.d configuration"
  rsync -rlv /var/nginx/conf.d/ /etc/nginx/conf.d/
fi
if [ -d "/var/nginx/default.d" ]; then
  echo "Using custom Nginx default.d configuration"
  rsync -rlv /var/nginx/default.d/ /etc/nginx/default.d/
fi

echo "Starting Nginx"
exec nginx

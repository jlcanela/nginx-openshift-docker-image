# Nginx OpenShift Docker Image

[![Circle CI](https://circleci.com/gh/AXA-GROUP-SOLUTIONS/nginx-openshift-docker-image/tree/master.svg?style=shield)](https://circleci.com/gh/AXA-GROUP-SOLUTIONS/nginx-openshift-docker-image/tree/master)
[![DockerHub](https://img.shields.io/badge/docker-axags%2Fnginx--openshift-008bb8.svg)](https://hub.docker.com/r/axags/nginx-openshift/)
[![Image Layers](https://badge.imagelayers.io/axags/nginx-openshift:latest.svg)](https://imagelayers.io/?images=axags/nginx-openshift:latest)

`axags/nginx-openshift` is a base Docker image that should be used to run nginx-based applications in an OpenShift environment.

### OpenShift specific requirements

* The container should run with a random UUID

This image use the [openshift/origin-base](https://hub.docker.com/r/openshift/origin-base/) base-image.

## Use Cases

* Serve some static files via HTTP

## How To Use

* If you just want to serve some static files, mount them at `/usr/share/nginx/html`

### Basic configuration through environment variables

Use environment variables to configure the default configuration:

* `NGINX_LISTEN_PORT` for the port used by Nginx (default to `8080`)

### Custom configuration

For more complex configuration needs, you can mount Nginx configuration files at `/var/nginx/conf.d` and/or `/var/nginx/default.d`, and they will be copied to `/etc/nginx/conf.d` and `/etc/nginx/default.d` after the default configuration generation.

You can also build a new image based on this one :

* create a `Dockerfile` :

  ```
  FROM axags/nginx-openshift
  COPY myhost.conf /etc/nginx/conf.d/
  ```
* create a `myhost.conf` file. For example, you serve static assets with nginx, and proxy the dynamic requests to a backend application running on another container in the same pod :

  ```
  server {
    listen 8080;
    server_name myhost.mydomain.tld;
    location /assets/ {
      alias /opt/myapp/assets/;
      expires 30d;
    }
    location / {
      proxy_pass          http://localhost:8888;
      proxy_read_timeout  30s;
      proxy_set_header    X-Real-IP  $remote_addr;
      proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header    Host $http_host;
    }
  }
  ```
* you can then have OpenShift build your new image by configuring a [BuildConfig](https://docs.openshift.org/latest/rest_api/openshift_v1.html#v1-buildconfig)

## Known issues

* Logs are not written to `stdout`/`stderr`, but to the `/var/log/nginx` volume, because of https://github.com/docker/docker/issues/6880

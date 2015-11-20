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
* Proxy a backend service
  * With extra Headers

## How To Use

* If you just want to serve some static files, mount them at `/usr/share/nginx/html`
* If you want to proxify a backend service, you can either configure the backend target through the `NGINX_PROXY_TARGET` environment variable (`http://host:port` syntax) or use a custom configuration.

Note that you can have a look at the `docker-compose.yml` for an example with both a proxy instance and a simple (backend) instance, and some custom headers.

### Basic configuration through environment variables

Use environment variables to configure the default configuration:

* `NGINX_LISTEN_PORT` for the port used by Nginx (default to `8080`)
* `NGINX_PROXY_*` for the proxy configuration, for example:
  * `NGINX_PROXY_TARGET` for the proxy target (`http://host:port` syntax)
  * `NGINX_PROXY_TIMEOUT_READ` for the proxy read timeout (`60s` by default)
  * `NGINX_PROXY_HEADER_*` to add headers to the proxyfied request, for examples:
    * `NGINX_PROXY_HEADER_1="X-Custom-Header-1 value"` to add a header `X-Custom-Header-1` with the value `value`
    * `NGINX_PROXY_HEADER_2="X-Custom-Header-2 \"My value\""` to add a header `X-Custom-Header-2` with the value `My value`

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

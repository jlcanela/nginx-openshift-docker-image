# Nginx OpenShift Docker Image

[![Circle CI](https://circleci.com/gh/vbehar/nginx-openshift-docker-image/tree/master.svg?style=shield)](https://circleci.com/gh/vbehar/nginx-openshift-docker-image/tree/master)
[![DockerHub](https://img.shields.io/badge/docker-vbehar%2Fnginx--openshift-008bb8.svg)](https://hub.docker.com/r/vbehar/nginx-openshift/)
[![Image Layers](https://badge.imagelayers.io/vbehar/nginx-openshift:latest.svg)](https://imagelayers.io/?images=vbehar/nginx-openshift:latest)

`vbehar/nginx-openshift` is a base Docker image that should be used to run nginx-based applications in an OpenShift environment.

### OpenShift specific requirements

* The container should run with a random UUID

This image use the [openshift/origin-base](https://hub.docker.com/r/openshift/origin-base/) base-image.

## Use Cases

* Serve some static files via HTTP
* Proxy a backend service
  * With custom redirection rules
  * With extra Headers

## How To Use

* If you just want to serve some static files, mount them at `/usr/share/nginx/html`
* If you want to proxify a backend service, you can either configure the backend target through the `NGINX_PROXY_TARGET` environment variable (`http://host:port` syntax) or use a custom configuration.

Note that you can have a look at the `docker-compose.yml` for an example with both a proxy instance and a simple (backend) instance, and some custom headers and redirection rules.

### Basic configuration through environment variables

Use environment variables to configure the default configuration:

* `NGINX_LISTEN_PORT` for the port used by Nginx (default to `8080`)
* `NGINX_LOG_*` for the access/error logs:
  * `NGINX_LOG_ACCESS` for the access logs. Default to `/var/log/nginx/access.log`, but can be set to `/dev/stdout` (if using Docker >= 1.9). In case of problem, read https://github.com/docker/docker/issues/6880
  * `NGINX_LOG_ERROR` for the error logs. Default to `/var/log/nginx/error.log`, but can be set to `/dev/stderr` (if using Docker >= 1.9). In case of problem, read https://github.com/docker/docker/issues/6880
* `NGINX_PROXY_*` for the proxy configuration, for example:
  * `NGINX_PROXY_TARGET` for the proxy target (`http://host:port` syntax)
  * `NGINX_PROXY_TIMEOUT_READ` for the proxy read timeout (`60s` by default)
  * `NGINX_PROXY_HEADER_*` to add headers to the proxyfied request, for examples:
    * `NGINX_PROXY_HEADER_1="X-Custom-Header-1 value"` to add a header `X-Custom-Header-1` with the value `value`
    * `NGINX_PROXY_HEADER_2="X-Custom-Header-2 \"My value\""` to add a header `X-Custom-Header-2` with the value `My value`
    * ...
* `NGINX_HEADER_*` to add headers, for example:
  * `NGINX_HEADER_1="X-Custom-Header-1 value"` to add a header `X-Custom-Header-1` with the value `value`
  * `NGINX_HEADER_2="X-Custom-Header-2 \"My value\""` to add a header `X-Custom-Header-2` with the value `My value`
  * ...
* `NGINX_REWRITE_*` to add rewrite rules:
  * `NGINX_REWRITE_PERMANENT_*` for permanent redirects (code 301), for example:
    * `NGINX_REWRITE_PERMANENT_1="/old /"` to add a permanent redirect (code 301) from `/old` to `/`
    * ...
  * `NGINX_REWRITE_TEMPORARY_*` for temporary redirects (code 302), for example:
    * `NGINX_REWRITE_TEMPORARY_1="/tmp /"` to add a temporary redirect (code 302) from `/tmp` to `/`
    * ...

### Custom configuration

For more complex configuration needs, you can mount Nginx configuration files at `/var/nginx/conf.d` and/or `/var/nginx/default.d`, and they will be copied to `/etc/nginx/conf.d` and `/etc/nginx/default.d` after the default configuration generation.

You can also build a new image based on this one :

* create a `Dockerfile` :

  ```
  FROM vbehar/nginx-openshift
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

* Logs are not written to the standard output by default, because of https://github.com/docker/docker/issues/6880 - TL;DR we can't use `/dev/stdout` and `/dev/stderr` without being `root` until Docker 1.9.

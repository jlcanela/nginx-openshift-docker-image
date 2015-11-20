FROM openshift/origin-base

MAINTAINER https://github.com/AXA-GROUP-SOLUTIONS/nginx-openshift-docker-image

ENV CONFD_VERSION 0.10.0
RUN echo "Installing Confd ${CONFD_VERSION} ..." \
 && curl -jksSL "https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64" > /usr/local/bin/confd \
 && chmod a+x /usr/local/bin/confd

RUN echo "Installing Nginx ..." \
 && yum install -y nginx \
 && yum clean all \
 && mkdir -p /var/lib/nginx && chmod -R 777 /var/lib/nginx \
 && mkdir -p /var/log/nginx && chmod -R 777 /var/log/nginx

COPY etc/nginx/ /etc/nginx/
RUN chmod 777 /etc/nginx \
 && mkdir -p /etc/nginx/default.d && chmod -R 777 /etc/nginx/default.d \
 && mkdir -p /etc/nginx/conf.d && chmod -R 777 /etc/nginx/conf.d

COPY usr/local/bin/ /usr/local/bin/
RUN chmod a+x /usr/local/bin/*
CMD ["start-nginx.sh"]

COPY etc/confd/ /etc/confd/

VOLUME ["/etc/nginx/default.d", "/etc/nginx/conf.d", "/var/log/nginx"]

# Default values
ENV NGINX_LISTEN_PORT=8080
EXPOSE 8080

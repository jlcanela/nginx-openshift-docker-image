FROM openshift/origin-base

MAINTAINER https://github.com/AXA-GROUP-SOLUTIONS/nginx-openshift-docker-image

RUN yum install -y nginx \
 && yum clean all \
 && mkdir -p /var/lib/nginx && chmod -R 777 /var/lib/nginx \
 && mkdir -p /var/log/nginx && chmod -R 777 /var/log/nginx

COPY etc/nginx/ /etc/nginx/

VOLUME ["/var/log/nginx"]

EXPOSE 8080

CMD ["nginx"]

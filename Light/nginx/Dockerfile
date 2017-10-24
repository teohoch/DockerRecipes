FROM nginx:latest

RUN rm -v /etc/nginx/conf.d/*
COPY config/portainer.conf /etc/nginx/conf.d/portainer.conf
COPY config/nginx.conf /etc/nginx/nginx.conf

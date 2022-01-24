FROM nginx:latest
ARG UID=1001
ENV NGINX_PORT=8000
ENV NGINX_ROOTDIR=/app
RUN usermod -u ${UID} nginx
COPY default.conf.template /etc/nginx/templates/
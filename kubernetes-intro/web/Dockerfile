#--------------------------------------------------------
# My Dockerfile: build Docker Image Nginx v.1
#--------------------------------------------------------
FROM nginx:mainline-alpine
WORKDIR /app
COPY ./app .
#COPY ./app /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8000
RUN chmod -R 777 /var/cache/nginx /run
USER 1001
STOPSIGNAL SIGQUIT
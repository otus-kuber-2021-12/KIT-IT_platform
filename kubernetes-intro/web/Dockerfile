#--------------------------------------------------------
# My Dockerfile: build Docker Image Nginx v.1
#--------------------------------------------------------
FROM nginx:1.20.2-alpine
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
WORKDIR /app
COPY ./app .
EXPOSE 8000
RUN chmod -R 777 /var/cache/nginx /run
USER 1001


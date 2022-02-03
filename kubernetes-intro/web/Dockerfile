FROM nginx:latest
WORKDIR /app
COPY /app/homework.html /app
COPY nginx.conf /etc/nginx/conf.d/
RUN touch /var/run/nginx.pid && \
  chown -R 1001:1001 /var/run/nginx.pid && \
  chown -R 1001:1001 /var/cache/nginx && \
  chown -R 1001:1001 /app 
USER 1001:1001
EXPOSE 8000
CMD ["nginx", "-g", "daemon off;"]
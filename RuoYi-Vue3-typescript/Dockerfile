FROM nginx:alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/
COPY dist .
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

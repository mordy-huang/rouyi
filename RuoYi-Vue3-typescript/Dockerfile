FROM node:18 AS build
WORKDIR /build
COPY package.json ./
RUN npm install --registry=https://registry.npmmirror.com
COPY . .
RUN npm run build:prod

FROM nginx:alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/
COPY --from=build /build/dist .
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

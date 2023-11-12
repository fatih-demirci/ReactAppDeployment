# Build the react app
FROM node:alpine AS builder
WORKDIR /app/src
COPY /ReactApp/package*.json .
RUN npm ci
COPY /ReactApp .
RUN npm run build

# Serve the application with nginx
FROM nginx:alpine
COPY /ReactApp/nginx.conf /etc/nginx/nginx.conf
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/src/dist /usr/share/nginx/html
RUN apk update && apk upgrade --no-cache
EXPOSE 80 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
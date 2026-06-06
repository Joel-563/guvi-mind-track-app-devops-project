#nginx image from dockerhub
FROM nginx:stable-alpine
#copying the dist folder content to the nginx web server data folder
COPY dist/ /web/data/
#copying the nginx.conf file to the nginx configuration folder
COPY nginx.conf /etc/nginx/conf.d/default.conf
#exposing port 3000 to access the application
EXPOSE 3000
# Brain Tasks App - DevOps Deployment Project

## Project Overview

This project is a DevOps deployment practice project for the Brain Tasks static frontend application. The application contains production-ready static files generated under the `dist` directory. The goal of this project is to containerize the application, test it locally using Docker and Nginx, and later deploy it to AWS EKS using CI/CD.

## Current Project Status

Completed:

* Cloned the application repository
* Verified that the application contains ready-to-deploy static files
* Created a Dockerfile using the official Nginx Alpine image
* Created a custom Nginx configuration
* Served the static application from a custom directory inside the container
* Configured Nginx to listen on port `3000`
* Built the Docker image locally
* Ran the Docker container locally
* Verified the application in browser at `http://localhost:3000`

Pending:

* Push project code to GitHub
* Create AWS ECR repository
* Push Docker image to ECR
* Create AWS EKS cluster
* Write Kubernetes Deployment and Service YAML files
* Deploy application to EKS
* Configure CodeBuild and CodePipeline
* Enable CloudWatch logging
* Capture screenshots and LoadBalancer details

## Application Structure

```text
Brain-Tasks-App/
├── dist/
│   ├── index.html
│   ├── vite.svg
│   └── assets/
│       ├── index-*.js
│       └── index-*.css
├── Dockerfile
├── nginx.conf
└── README.md
```

## Why Nginx Was Used

The application contains static frontend files inside the `dist` directory. Since no backend server or build step is required at runtime, Nginx is used as a lightweight web server to serve the static HTML, CSS, and JavaScript files.

## Docker Image Build

```bash
docker build -t brain-task-app .
```

## Run Container Locally

```bash
docker run -d -p 3000:3000 --name brain-task brain-task-app
```

## Verify Running Container

```bash
docker ps
```

## View Container Logs

```bash
docker logs brain-task
```

## Access Application

```text
http://localhost:3000
```

## Nginx Configuration Summary

The custom Nginx configuration listens on port `3000`, serves files from `/web/data`, and uses `try_files` to return `index.html` for frontend routes.

## Docker Concepts Learned

* Difference between Docker image and container
* Difference between `docker stop`, `docker rm`, and `docker rmi`
* Port mapping using `-p HOST_PORT:CONTAINER_PORT`
* Why `EXPOSE` documents a port but does not publish it
* How Nginx serves static files from a root directory
* Why files inside `/etc/nginx/conf.d/` should contain a `server` block, not an `http` block

## Next Step

The next step is to push this codebase to GitHub and then create an AWS ECR repository for storing the Docker image.

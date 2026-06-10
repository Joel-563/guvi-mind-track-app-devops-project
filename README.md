# Brain Tasks App - Production Deployment Walkthrough

This repository contains the deployment setup for the **Brain Tasks** React application. The application was containerized with Docker, pushed to Docker Hub, deployed to AWS EKS through a CI/CD flow, exposed through a Kubernetes `LoadBalancer` service on port `3000`, and monitored using Amazon CloudWatch.

## Deployment Summary

| Item                        | Value                                                                                               |
| --------------------------- | --------------------------------------------------------------------------------------------------- |
| Application                 | Brain Tasks App                                                                                     |
| GitHub repository           | `https://github.com/Joel-563/guvi-mind-track-app-devops-project.git`                                |
| Original application source | `https://github.com/Vennilavanguvi/Brain-Tasks-App.git`                                             |
| Application port            | `3000`                                                                                              |
| Container image             | `joelrobinson791/brain-task-app:latest`                                                             |
| Kubernetes namespace        | `test`                                                                                              |
| EKS cluster                 | `brain-task-app-cluster`                                                                            |
| Kubernetes deployment       | `brain-tasks-app`                                                                                   |
| Kubernetes service          | `brain-tasks-app-service`                                                                           |
| Service type                | `LoadBalancer`                                                                                      |
| LoadBalancer DNS            | `a024fa4dff4864cd1891b3daa54b41d0-171315576.us-east-1.elb.amazonaws.com:3000`                       |
| LoadBalancer ARN            | `arn:aws:elasticloadbalancing:us-east-1:097096558664:loadbalancer/a024fa4dff4864cd1891b3daa54b41d0` |
| CloudWatch log group        | `/aws/codebuild/brain-task-app-guvi`                                                                |

## Architecture

```text
GitHub Repository
      |
      v
AWS CodePipeline / CodeBuild
      |
      |-- Docker login
      |-- Docker image build
      |-- Docker image push to Docker Hub
      |-- EKS kubeconfig update
      |-- kubectl apply deployment.yaml
      |-- kubectl apply service.yaml
      v
AWS EKS Cluster
      |
      v
Kubernetes LoadBalancer Service
      |
      v
Brain Tasks App on port 3000
```

## Repository Structure

```text
Brain-Tasks-App/
|-- dist/
|   |-- index.html
|   |-- vite.svg
|   `-- assets/
|-- screenshots/
|-- Dockerfile
|-- nginx.conf
|-- deployment.yaml
|-- service.yaml
|-- nodepool.yaml
|-- buildspec.yml
`-- README.md
```

## 1. Version Control

The application repository was pushed to GitHub. The commit history shows the Dockerfile work and the CodeBuild buildspec update.

```bash
git add .
git commit -m "docker file created and tested locally"
git commit -m "trial build spec"
git push origin main
```

<p>
  <img src="screenshots/Screenshot%202026-06-10%20113459.png" alt="GitHub commit history for Brain Tasks App" width="900">
</p>

## 2. Dockerization

The application is a static React build available in the `dist` folder. Nginx is used to serve the static frontend files from inside the container.

### Dockerfile

```dockerfile
FROM nginx:stable-alpine
COPY dist/ /web/data/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 3000
```

### Nginx Configuration

```nginx
server {
  listen 3000;
  root /web/data;
  location / {
    try_files $uri $uri/ /index.html;
  }
}
```

### Local Docker Build

```bash
docker build -t brain-task-app .
```

### Local Docker Run

```bash
docker run -d -p 3000:3000 --name brain-task brain-task-app
```

### Verify Locally

```bash
docker ps
docker logs brain-task
```

After running the container, the app can be opened at:

```text
http://localhost:3000
```

## 3. Docker Registry

Docker Hub was used as the container registry.

```bash
docker tag brain-task-app joelrobinson791/brain-task-app:latest
docker push joelrobinson791/brain-task-app:latest
```

The CI/CD build also creates a commit-based image tag and a readable `latest` tag.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20121812.png" alt="Docker Hub image tags for Brain Tasks App" width="900">
</p>

## 4. CodeBuild Setup

AWS CodeBuild was configured to build the Docker image, push it to Docker Hub, and deploy the application to EKS using `kubectl`.

### Required Environment Variables

| Variable           | Purpose                                                |
| ------------------ | ------------------------------------------------------ |
| `DOCKER_USERNAME`  | Docker Hub username                                    |
| `DOCKER_TOKEN`     | Docker Hub access token stored in Secrets Manager      |
| `IMAGE_NAME`       | Docker image name, for example `brain-task-app`        |
| `AWS_REGION`       | AWS region, for example `us-east-1`                    |
| `EKS_CLUSTER_NAME` | EKS cluster name, for example `brain-task-app-cluster` |
| `K8S_NAMESPACE`    | Kubernetes namespace, for example `test`               |

<p>
  <img src="screenshots/Screenshot%202026-06-10%20121330.png" alt="CodeBuild environment variables" width="900">
</p>

The Docker Hub token was stored in AWS Secrets Manager and referenced by CodeBuild.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20121321.png" alt="Docker Hub token stored in AWS Secrets Manager" width="900">
</p>

### buildspec.yml Flow

The `buildspec.yml` file performs these actions:

1. Logs in to Docker Hub.
2. Creates a unique Docker image tag from the commit hash.
3. Builds the Docker image.
4. Pushes both the unique tag and the `latest` tag to Docker Hub.
5. Updates kubeconfig for the EKS cluster.
6. Applies the Kubernetes deployment and service files.
7. Waits for the LoadBalancer DNS name.

Initial Docker validation in CodeBuild:

<p>
  <img src="screenshots/Screenshot%202026-06-10%20114726.png" alt="CodeBuild docker version check" width="900">
</p>

<p>
  <img src="screenshots/Screenshot%202026-06-10%20114736.png" alt="CodeBuild docker info check" width="900">
</p>

Initial buildspec validation:

<p>
  <img src="screenshots/Screenshot%202026-06-10%20114808.png" alt="Initial buildspec Docker check commands" width="900">
</p>

Successful Docker Hub login in CodeBuild:

<p>
  <img src="screenshots/Screenshot%202026-06-10%20121742.png" alt="Successful Docker Hub login in CodeBuild" width="900">
</p>

Docker image build in CodeBuild:

<p>
  <img src="screenshots/Screenshot%202026-06-10%20121749.png" alt="Docker image build logs in CodeBuild" width="900">
</p>

## 5. EKS Cluster Setup

An AWS EKS cluster named `brain-task-app-cluster` was created with custom configuration.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20123647.png" alt="EKS custom cluster configuration" width="900">
</p>

The cluster was attached to the selected VPC and subnets.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20123719.png" alt="EKS VPC and subnet selection" width="900">
</p>

The Amazon VPC CNI add-on was configured for cluster networking.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20123731.png" alt="Amazon VPC CNI add-on setup" width="900">
</p>

EKS Auto Mode was not used, so compute capacity was configured through a node group.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20124123.png" alt="EKS compute configuration" width="900">
</p>

A managed node group was created for worker nodes.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20125509.png" alt="EKS managed node group setup" width="900">
</p>

## 6. Kubernetes Deployment

The application was deployed using `deployment.yaml` and `service.yaml`.

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: brain-tasks-app
  namespace: test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: brain-tasks-app
  template:
    metadata:
      labels:
        app: brain-tasks-app
    spec:
      containers:
        - name: brain-tasks-app
          image: joelrobinson791/brain-task-app:latest
          ports:
            - containerPort: 3000
```

### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: brain-tasks-app-service
  namespace: test
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
spec:
  selector:
    app: brain-tasks-app
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
  type: LoadBalancer
```

### Manual Kubernetes Commands

These commands can be used to deploy manually from a terminal:

```bash
aws eks update-kubeconfig --region us-east-1 --name brain-task-app-cluster
kubectl create namespace test
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl rollout status deployment/brain-tasks-app -n test
kubectl get svc brain-tasks-app-service -n test
```

## 7. CodePipeline / CI-CD Deployment

The pipeline uses GitHub as the source and AWS CodeBuild as the build/deploy stage.

CI/CD execution flow:

1. CodePipeline detects a change in GitHub.
2. CodeBuild starts and reads `buildspec.yml`.
3. CodeBuild builds the Docker image.
4. Docker image is pushed to Docker Hub.
5. CodeBuild connects to EKS using `aws eks update-kubeconfig`.
6. Kubernetes manifests are applied using `kubectl`.
7. Kubernetes creates or updates the application pods and LoadBalancer service.

Successful Kubernetes deployment from CodeBuild:

<p>
  <img src="screenshots/Screenshot%202026-06-10%20180205.png" alt="CodeBuild deploys application to EKS and prints LoadBalancer URL" width="900">
</p>

## 8. Application Verification

After deployment, the Kubernetes LoadBalancer exposed the application on port `3000`.

Application URL:

```text
http://a024fa4dff4864cd1891b3daa54b41d0-171315576.us-east-1.elb.amazonaws.com:3000
```

The application was successfully opened in the browser through the AWS LoadBalancer.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20180358.png" alt="Brain Tasks App running through AWS LoadBalancer" width="900">
</p>

AWS Load Balancer entry:

<p>
  <img src="screenshots/Screenshot%202026-06-10%20182213.png" alt="AWS load balancer list entry" width="900">
</p>

AWS Load Balancer DNS details:

<p>
  <img src="screenshots/Screenshot%202026-06-10%20182222.png" alt="AWS load balancer DNS details" width="900">
</p>

## 9. Monitoring

Amazon CloudWatch was used to track CodeBuild build logs and deployment activity.

CloudWatch log group:

```text
/aws/codebuild/brain-task-app-guvi
```

CloudWatch log group details:

<p>
  <img src="screenshots/Screenshot%202026-06-10%20182717.png" alt="CloudWatch CodeBuild log group details" width="900">
</p>

A CloudWatch alarm was configured for CodeBuild `FailedBuilds`.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20183426.png" alt="CloudWatch alarm for CodeBuild failed builds" width="900">
</p>

CodeBuild metrics were also visible in CloudWatch.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20183601.png" alt="CloudWatch CodeBuild metrics graph" width="900">
</p>

## 10. Issues Faced and Fixes

### Docker Login Failed

The first Docker login failed because CodeBuild could not authenticate with Docker Hub.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20115123.png" alt="CodeBuild Docker login failed" width="900">
</p>

Fix:

- Created a Docker Hub access token.
- Stored the token in AWS Secrets Manager.
- Added `DOCKER_TOKEN` in CodeBuild as a Secrets Manager environment variable.

### CodeBuild Could Not Read Secret

CodeBuild initially failed to read the Docker Hub secret because the service role did not have permission to call `secretsmanager:GetSecretValue`.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20121414.png" alt="CodeBuild Secrets Manager permission error" width="900">
</p>

Fix:

- Updated the CodeBuild service role IAM policy.
- Allowed access to the Docker Hub token stored in Secrets Manager.

### kubectl Could Not Connect to EKS

At one point, `kubectl apply` failed because kubeconfig was not correctly available in the CodeBuild environment.

<p>
  <img src="screenshots/Screenshot%202026-06-10%20162422.png" alt="kubectl kubeconfig connection issue in CodeBuild" width="900">
</p>

Fix:

- Updated kubeconfig inside CodeBuild using:

```bash
aws eks update-kubeconfig \
  --region $AWS_REGION \
  --name $EKS_CLUSTER_NAME \
  --alias $EKS_CLUSTER_NAME \
  --kubeconfig /temp/kubeconfig
```

- Used the same kubeconfig path for all `kubectl` commands:

```bash
kubectl --kubeconfig /temp/kubeconfig apply -f deployment.yaml
kubectl --kubeconfig /temp/kubeconfig apply -f service.yaml
```

## Final Result

The Brain Tasks application was successfully:

- Dockerized with Nginx.
- Built and tested on port `3000`.
- Pushed to Docker Hub.
- Deployed to AWS EKS.
- Exposed through an AWS LoadBalancer.
- Verified in the browser.
- Monitored with CloudWatch logs, metrics, and alarms.

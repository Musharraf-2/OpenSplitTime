# Kubernetes Deployment Guide

This guide will help you deploy your Rails application on Kubernetes using various components like persistent storage, Redis, Postgres, Sidekiq, and the NGINX Ingress Controller.

## Prerequisites
Before proceeding, ensure you have the following:
- A Kubernetes cluster (e.g., using Minikube, GKE, or another provider)
- `kubectl` configured to interact with your cluster
- Docker installed and configured to build images
- Your application code and Kubernetes YAML files are organized as described below

## Steps to Deploy

### 1. Build the Docker Image for the App
First, build your Docker image for the app.

```bash
docker image build -t app-image .
```

### 2. Apply Kubernetes Secrets
If you have any sensitive data (e.g., database credentials), store them in Kubernetes secrets. Apply them using the following command:

```bash
kubectl apply -f secrets/secrets.yaml
```

### 3. Create Persistent Volumes and Volume Claims
To ensure your database data and other stateful applications persist across pod restarts, apply the persistent volume configurations.

```bash
kubectl apply -f persistent-volumes/postgres-persistent-volumes.yaml
kubectl apply -f persistent-volume-claims/postgres-persistent-volumes-claims.yaml
```

### 4. Deploy Postgres, Redis, and Sidekiq
Deploy the necessary components: Postgres (for the database), Redis (for caching), and Sidekiq (for background jobs).

```bash
kubectl apply -f deployments/postgres-deployment.yaml
kubectl apply -f deployments/redis-deployment.yaml
kubectl apply -f deployments/sidekiq-deployment.yaml
```

### 5. Deploy the Main App
Deploy your main app to Kubernetes.

```bash
kubectl apply -f deployments/app-deployment.yaml
```

### 6. Create Services for the App
Expose the Postgres, Redis, and App deployments as services so other components can interact with them.

```bash
kubectl apply -f services/postgres-service.yaml
kubectl apply -f services/redis-service.yaml
kubectl apply -f services/app-service.yaml
```

### 7. Run Database Migrations (Optional)
If you need to run database migrations, use the following job. This job will run the migrations on the Postgres database.

```bash
kubectl apply -f jobs/migrate-job.yaml
```

### 8. Deploy NGINX Ingress Controller
Install the NGINX Ingress Controller to manage ingress traffic.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/cloud/deploy.yaml
```

### 9. Deploy Ingress for the App
Create an Ingress resource to expose the app externally via the NGINX Ingress Controller.

```bash
kubectl apply -f ingress/app-ingress.yaml
```

### 10. Port-Forward to Access the App Locally
To access your application from the local machine, use port forwarding. This will forward traffic from port `3000` on your local machine to port `80` on the NGINX Ingress Controller:

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 3000:80
```

You can now access the app via `http://localhost:3000`.

## Verifying the Deployment

1. **Check Pods**
   Verify that all pods are running:

   ```bash
   kubectl get pods
   ```

2. **Check Services**
   Verify that the services have been created:

   ```bash
   kubectl get services
   ```

3. **Check Ingress**
   Verify that the Ingress is set up:

   ```bash
   kubectl get ingress
   ```

4. **View Logs**
   If something goes wrong, you can check the logs for troubleshooting:

   ```bash
   kubectl logs <pod-name>
   ```

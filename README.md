# 🐮 Wisecow – GitOps CI/CD Deployment using GitHub Actions & Kubernetes (K3s on AWS EC2)

This project demonstrates a complete **CI/CD pipeline** for deploying a sample application (**Wisecow**) using **Docker**, **GitHub Actions**, and **Kubernetes (K3s)** running on an **AWS EC2 instance**.  
The app generates fun quotes using `fortune` and `cowsay` and serves them over HTTP.

---

## 🚀 Project Overview

The goal was to automate the entire deployment pipeline:
1. Build and package the app into a Docker image.  
2. Push the image to a remote repository.  
3. Automatically deploy it to a Kubernetes cluster (K3s) hosted on EC2 via GitHub Actions.  

This setup follows the **DevOps GitOps** approach — where the source code is the single source of truth, and deployment happens automatically on each update.

---

## 🧰 Tools & Technologies

| Tool | Purpose |
|------|----------|
| **AWS EC2 (Ubuntu 22.04)** | Host for Kubernetes cluster |
| **K3s** | Lightweight Kubernetes distribution |
| **Docker** | Build and containerize the application |
| **GitHub Actions** | CI/CD automation |
| **kubectl** | Manage Kubernetes cluster |assessment/
├── app/
│ ├── wisecow.sh
│ ├── Dockerfile
│ └── requirements.txt (if needed)
├── k8s/
│ ├── deployment.yaml
│ └── service.yaml
├── .github/
│ └── workflows/




| **fortune, cowsay, nc** | Fun terminal utilities used in app |
| **YAML Manifests** | Define Deployment and Service for Kubernetes |

---

## 📂 Project Structure

assessment/
├── app/
│ ├── wisecow.sh
│ ├── Dockerfile
│ └── requirements.txt (if needed)
├── k8s/
│ ├── deployment.yaml
│ └── service.yaml
├── .github/
│ └── workflows/
│ └── deploy.yml



---

## 🐋 Docker Setup

**Build the image:**
```bash
docker build -t wisecow:latest .


docker run --rm -p 4499:4499 wisecow:latest


docker tag wisecow:latest technicalgaur/wisecow:latest
docker push technicalgaur/wisecow:latest

```

# ☸️ Kubernetes Deployment

Deployment YAML (k8s/deployment.yaml)


```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wisecow-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wisecow
  template:
    metadata:
      labels:
        app: wisecow
    spec:
      containers:
      - name: wisecow
        image: technicalgaur/wisecow:latest
        ports:
        - containerPort: 4499
```

Service YAML (k8s/service.yaml)


```
apiVersion: v1
kind: Service
metadata:
  name: wisecow-service
spec:
  selector:
    app: wisecow
  ports:
    - protocol: TCP
      port: 4499
      targetPort: 4499
      nodePort: 30499
  type: NodePort
```


Apply manually (if needed):

```
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

⚙️ GitHub Actions (CI/CD Pipeline)

Workflow file: .github/workflows/deploy.yml

When you push changes to the main branch:

GitHub Actions connects to your EC2 instance via SSH.

It runs kubectl apply to update the deployment & service.

Sample snippet:

```
- name: Deploy to Kubernetes
  uses: appleboy/ssh-action@v0.1.6
  with:
    host: ${{ secrets.HOST }}
    username: ubuntu
    key: ${{ secrets.SSH_KEY }}
    script: |
      export PATH=$PATH:/usr/local/bin
      kubectl apply -f ~/assessment/k8s/deployment.yaml
      kubectl apply -f ~/assessment/k8s/service.yaml
```

# 🌐 Access the App

After deployment, check the service:
```
kubectl get svc
```

Example output:

```
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
wisecow-service   NodePort    10.43.195.171   <none>        4499:30499/TCP   5m
```

Now open in browser:

<img width="412" height="262" alt="Screenshot 2025-10-27 164002" src="https://github.com/user-attachments/assets/4c763ddb-e4df-4415-ba24-767915a44050" />



# ✅ Summary

This project covers:

CI/CD pipeline using GitHub Actions

Automated Kubernetes deployment via SSH

Running K3s cluster on EC2

Deploying and exposing containerized application

# 🧠 Future Improvements

Integrate Ingress instead of NodePort

Use Helm charts for deployment

Add Prometheus + Grafana for monitoring

Store images in DockerHub or GitHub Container Registry


# Screenshot

<img width="1097" height="586" alt="image" src="https://github.com/user-attachments/assets/7ed9e418-4332-4a45-b69c-609934b464a5" />



<img width="1362" height="588" alt="image" src="https://github.com/user-attachments/assets/229480ba-14a5-44be-934d-9907c08e065f" />



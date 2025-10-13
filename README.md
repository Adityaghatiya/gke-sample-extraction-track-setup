# 🚀 Project Title: Deploy Django-based Simple Extraction App on Minikube

This repository contains the complete solution for deploying the provided Django application — **Simple-Extraction-Demo-Track** — to a local Kubernetes cluster using **Minikube**.

The solution follows modern **cloud-native best practices**, including:
- ✅ Multi-stage Docker containerization  
- 🔐 Configuration management using **Secrets** and **ConfigMaps**  
- 💚 Health checks (Liveness and Readiness probes)  
- 🗄️ Persistent **PostgreSQL** database with data persistence  
- 🌐 Ingress-based local access at **http://demo.local**

---

## 🏗️ 1. Architectural Overview

### 🧭 1.1 Conceptual GCP Architecture
While the application is deployed on **Minikube**, this section outlines the conceptual, production-grade architecture for deployment on **Google Cloud Platform (GCP)**.

![habot_io](https://github.com/user-attachments/assets/59149ae3-c479-457b-9606-397d36e1dd54)

---

### 🧩 1.2 Local Minikube Architecture

The implementation uses the following Kubernetes resources to run the application locally:

1. **Django Application (Deployment):** Runs the production-optimized Docker image.  
2. **InitContainer:** Handles mandatory database migrations (`manage.py migrate`) before the main container starts — ensuring idempotency and graceful initial deployment.  
3. **Probes:** Implements **Liveness** and **Readiness** probes for zero-downtime updates.  
4. **PostgreSQL (StatefulSet):** Deploys the database with persistent storage.  
5. **PersistentVolumeClaim (PVC):** Ensures data persistence across pod restarts.  
6. **Configuration:** All credentials and environment settings are securely injected using **Secrets** and **ConfigMaps**.  

![minikubearchitecture](https://github.com/user-attachments/assets/bcbc7d4e-ff89-4799-9a35-84d33b60720a)


#### 🌐 Networking Overview

- A **ClusterIP Service** exposes the Django application internally on port `80`.  
- An **Ingress** resource maps the external hostname **demo.local** to the internal service, making the app accessible from your local system.  

---

## ⚙️ 2. Minikube Setup

### 🧰 Install Minikube

For setting up the Minikube cluster on your local system, first install **Docker Desktop**, then run:

```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```

Or take reference from the official Minikube website according to your system:
👉 https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download

### ▶️ Start the Minikube Cluster

From a terminal with administrator access (but not logged in as root), run:
```
minikube start
```
### 🔍 Interact with Your Cluster

If you already have kubectl installed (see documentation), you can now use it to access your new cluster:
```
kubectl get po -A
```
---
## 🧬 3. Clone the Application Repository

Parallely, clone the app repository to your local system:
```
git clone <repo-url>
```
```
cd Simple-Extraction-Demo-Track
```
---
## 🐳 4. Build Docker Image

Run the following command to build the Docker image:
```
eval $(minikube docker-env)
docker build -t simple-extraction:latest .
```

Check if the Docker image is built successfully:
```
docker images
```
---
## 🧾 5. Kubernetes Deployment (Manifests)

Inside this repo, the k8-manifest directory contains all Kubernetes YAML configuration files:
```
deployment.yaml – Django and PostgreSQL deployments

ingress.yaml – Ingress configuration

#secret.yaml – Application and database credentials

#configmap.yaml – Environment configuration

Navigate to the manifests directory:

cd k8-manifest
```

Apply all manifests at once:
```
kubectl apply -f .
```

Or apply them one by one:
```
kubectl apply -f <filename>.yaml
```
---
## 📊 6. Verify Deployments
#### 🧩 Check Services
```
kubectl get svc --all-namespaces
```
<img width="1702" height="215" alt="image" src="https://github.com/user-attachments/assets/4b14e5df-b281-415d-90d1-0fd888a27510" />

<img width="1506" height="151" alt="image" src="https://github.com/user-attachments/assets/7b80dd1c-3d53-428a-9076-672c66ef7b33" />

To check a specific service:
```
kubectl get svc django -n default
```
<img width="1581" height="91" alt="image" src="https://github.com/user-attachments/assets/9d43d5a8-4a2b-4105-b189-0bc0cef21592" />

To see the complete configuration, status events, and detailed information for a specific service, use the describe command:
```
   kubectl describe svc django
```

<img width="1851" height="417" alt="image" src="https://github.com/user-attachments/assets/21174894-85f9-4b14-9a65-fa042cac8dcb" />

#### 🧱 Check Pods:- 
```
kubectl get pods
kubectl get pods -o wide
```

To see the complete configuration, status events, and detailed information for a specific pod, use the describe command:
```
kubectl describe pod <pod-name>
# Example:
kubectl describe pod django-deployment-abcde-12345
```
<img width="1919" height="1101" alt="image" src="https://github.com/user-attachments/assets/5577c8f4-c79b-4d7e-b180-086ccb391fad" />

Now for debuging and for checking logs of any deployment and pods use this  cmd:-
```
kubectl logs <pod name>
```

<img width="1919" height="966" alt="image" src="https://github.com/user-attachments/assets/041e6ba9-456c-4a68-aea0-ff0802874c46" />

For running cmd inside any pods use this cmd or  an interactive shell inside the running pod. :-

```
kubectl exec -it django-6bb67b8768-rslwz -- bash
```

<img width="1880" height="51" alt="image" src="https://github.com/user-attachments/assets/8a5da1d5-0890-43ed-a62c-a0dbc5d95c53" />

---
##  7. Ingress Controller and Networking Setup
The project requires the Django application to be accessible externally via the hostname http://localhost. This is achieved using a Kubernetes Ingress resource, which relies on an Ingress Controller. Minikube makes this straightforward by providing a built-in addon.

#### Enabling the Minikube Ingress Addon
The Ingress Controller is required to monitor the Ingress resource and manage the routing rules. This command must be executed after starting Minikube:
```
minikube addons enable ingress
```

#### Local Hosts File Configuration
The Minikube IP address must be mapped to the hostname demo.local on your local machine to resolve the domain name correctly.

Get Minikube IP:
```
# Get Minikube IP:
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"
```
Add Entry to /etc/hosts:
```
echo "$MINIKUBE_IP demo.local" | sudo tee -a /etc/hosts
```
---
### 8. Access the Application

Once the ingress and services are active, access your Django application locally at:

```
kubectl port-forward service/django 8000:8000
```
👉 [http://demo.local](http://localhost:8000/)
<img width="1919" height="1160" alt="image" src="https://github.com/user-attachments/assets/63b5b909-cf4a-4429-8554-87b133f16ef1" />

---
## 🔒 Security & Configuration Management

Instead of hardcoding secrets or credentials in your code or Kubernetes manifests, you can manage them securely using Kubernetes Secrets and ConfigMaps.
### 🧩 How It Works

You:

Create a ConfigMap or Secret.

Attach it to your Pod using:

1.Environment variables

Your app reads the values from the injected location at runtime.
#### ⚙️ Example: Using a Secret
Step 1 – Create a Secret
```
kubectl create secret generic mysecret \
  --from-literal=password=mypass123
```
Step 2 – Create a Pod using that Secret
```
apiVersion: v1
kind: Pod
metadata:
  name: secret-demo
spec:
  containers:
    - name: busybox
      image: busybox
      command: ["sleep", "3600"]
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: password
```
Step 3 – Apply and Verify
```
kubectl apply -f pod.yaml
kubectl exec -it secret-demo -- printenv DB_PASSWORD
```

✅ You’ll see the password securely injected into the container environment — without ever exposing it in your source code.

#### Real-World Analogy
Imagine you’re deploying an app on a shared team server then:-

1. Hardcoding passwords in the app = leaving your house key in plain sight
2. Using ConfigMaps and Secrets = storing your keys in a locked drawer with access logs

## But here as local deployment we use this .env method

Step 1. Keep a .env file locally (ignored by Git).
Step 2. Use it to create your Kubernetes Secre
```
kubectl create secret generic django-secret --from-env-file=.env
```

This automatically creates the secret in the cluster, but it’s not part of your version-controlled YAML








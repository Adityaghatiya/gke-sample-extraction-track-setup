## 🧭 OVERVIEW – What we’ll do
✅ Enable GKE and Artifact Registry on Google Cloud
🐳 Build and push your Docker image to Artifact Registry
⚙️ Create Kubernetes manifests (Deployment, Service, Secrets, Postgres DB)
🚀 Deploy to GKE
🌐 Access your Django website
![hbotio (1)](https://github.com/user-attachments/assets/c6dd487b-e577-48d3-ab6a-4643ff0c1f4b)


## 🔹 Step 1: Enable GKE and Artifact Registry

Open your Cloud Shell or local terminal (with gcloud installed and configured).
```
gcloud auth login
gcloud config set project <YOUR_PROJECT_ID>
```
<img width="822" height="326" alt="image" src="https://github.com/user-attachments/assets/b86ed352-fab4-434b-8fcb-f31273ea6184" />

Then enable APIs:
```
gcloud services enable container.googleapis.com artifactregistry.googleapis.com
```
<img width="1292" height="105" alt="image" src="https://github.com/user-attachments/assets/00197933-4686-4b7b-a755-9fad090c6f25" />

### 🔹 Step 2: Create an Artifact Registry repository

Set vars (replace <PROJECT_ID>):
```
export PROJECT=<PROJECT_ID>
export REGION=us-central1
export REPO=extraction-repo
export IMAGE=extraction
export TAG=latest
```
Confirm this ran correctly:
```
echo $PROJECT $REGION $REPO $IMAGE $TAG
```

Create Artifact Registry :
```
gcloud artifacts repositories create $REPO \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repo for extraction app" \
  --project=$PROJECT
```
<img width="1523" height="426" alt="image" src="https://github.com/user-attachments/assets/1890c008-e135-4603-b7ec-456b47e60ca2" />

Then configure Docker authentication:
```
gcloud auth configure-docker ${REGION}-docker.pkg.dev --project=$PROJECT
```
<img width="1133" height="770" alt="image" src="https://github.com/user-attachments/assets/0dcd2259-22a4-4219-a8fc-0fdc12ecc378" />

### 🔹 Step 3: Build and Push Docker Image to Artifact Registry

From your project root (where the Dockerfile lives):
```
docker build -t us-central1-docker.pkg.dev/<PROJECT_ID>/extraction-repo/extraction:latest .
```
<img width="1881" height="708" alt="image" src="https://github.com/user-attachments/assets/b2f71473-5896-4749-8f47-8a6dcf7ce863" />
Checking the image:
```
docker images
```
<img width="1328" height="94" alt="image" src="https://github.com/user-attachments/assets/22e0e658-e86d-41c1-9c29-8053e533dc24" />

Push the image:
```
docker push asia-south1-docker.pkg.dev/<PROJECT_ID>/extraction-repo/extraction:latest
```
Now checking the image
```
export IMAGE_PATH=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE}:${TAG}
echo $IMAGE_PATH
```
<img width="1556" height="80" alt="image" src="https://github.com/user-attachments/assets/196b5bf6-2e60-41d8-b23d-9558fc632ebc" />

✅ This image will be pulled by your GKE cluster later.

### 🔹 Step 4: Create a GKE Cluster
```
gcloud container clusters create extraction-cluster \
  --num-nodes=2 \
  --machine-type=e2-medium \
  --region=asia-south1

```
<img width="1466" height="471" alt="image" src="https://github.com/user-attachments/assets/d7554e91-d7dd-4623-afe0-baad8112f00d" />

Connect kubectl to the cluster:
```
gcloud container clusters get-credentials extraction-cluster --region=asia-south1
```
<img width="1866" height="91" alt="image" src="https://github.com/user-attachments/assets/398b3f35-a653-48a9-a9d7-b7ec79d29628" />

Now check:
```
kubectl get nodes
```
<img width="1029" height="90" alt="image" src="https://github.com/user-attachments/assets/71435d75-4b62-4758-a6dd-9755414829e4" />

✅ You should see your nodes ready.

### 🔹 Step 5: Create Kubernetes Namespace

We’ll isolate everything in a namespace:
```
kubectl create namespace django-gke
```
<img width="1091" height="254" alt="image" src="https://github.com/user-attachments/assets/531b4576-5669-4e23-b5b3-75c2aae6af98" />

### 🔹 Step 6: Manifest file inside the k8s folder in root is ready.Here it contain deployment, service , ingress, persistent volume clam, statefull set,etc
```
kubectl apply -f k8s/
```
<img width="992" height="218" alt="image" src="https://github.com/user-attachments/assets/6b701f48-aa80-44f8-b713-c32a2a748df7" />

###  🔹 Step 7: Checking Deployment ,service, pods
For checking service 
```
kubectl get svc -n django-gke
```
<img width="1061" height="81" alt="image" src="https://github.com/user-attachments/assets/5c2e7d67-1419-477d-991f-c24d4e2c61e8" />
For checking the deployment 
```
kubectl get deployment -n django-gke
```
<img width="1121" height="62" alt="image" src="https://github.com/user-attachments/assets/6a227ced-8a7c-4e80-85b0-adfeaf1b7e1d" />

For checking the pods
```
kubectl get pods -n django-gke
```
<img width="1089" height="79" alt="image" src="https://github.com/user-attachments/assets/19ed7f8b-d76a-414b-b4e1-cc55fb46990d" />

For chekcing the ingress setup
```
kubectl get ingress  -n django-gke
```
<img width="603" height="63" alt="image" src="https://github.com/user-attachments/assets/17b0b1b6-269a-4985-b8db-a3419e825374" />
<img width="1502" height="587" alt="image" src="https://github.com/user-attachments/assets/0dc9e57d-8e3f-405c-9238-10b910979b32" />

### 🔹 Step 8: Access the Application
Once the ingress and services are active, access your Django application with loadbalancer ip:
<img width="1919" height="1012" alt="image" src="https://github.com/user-attachments/assets/ebe9b9bc-8ee3-46ae-b5aa-fe0f3ea30b0b" />

### For Troubleshooting part:-
#### If we get error in the pods running or crashbackloop then:-
```
kubectl describe pod -n django-gke | grep -A 10 "Failed"

```
or
```
kubectl describe pod django-extraction-7b754b8c79-gh885 -n django-gke

```

#### For checking logs or debug  it:- 
Let’s check its logs:
```
kubectl logs <pods-name> -n django-gke
```
#### For replacing the pods
```
kubectl delete pod <pods-name> -n django-gke
kubectl apply -f k8s/django-deployment.yaml
```


for restart the pods to pull the fresh image:
```
kubectl rollout restart deployment django-extraction -n django-gke

```
Then check rollout status:
```
kubectl rollout status deployment django-extraction -n django-gke
```
### For checking application is fully functional
✅ Step 1: Check Django Pod Logs

Run:
```
kubectl logs -n django-gke deploy/django-extraction
```
✅ Step 2: Verify Database Pod :- 
Check PostgreSQL pod is Running:
```
kubectl get pods -n django-gke -l app=postgres
```
✅ Step 3: Enter Django Pod & Test DB Connection
Run:
```
kubectl exec -it -n django-gke deploy/django-extraction -- python manage.py showmigrations
```

If it lists migrations with [X] or [ ]:
→ Database is connected successfully.

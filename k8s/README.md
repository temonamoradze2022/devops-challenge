# About K8S environment

Application gets deployed into GKE cluster. 
Dedicated GCP service account has been created to deploy into GKE cluster.
Installed resources:

- Nginx ingress controller
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
--namespace=ingress-nginx \
--set controller.ingressClass="ingress-nginx"
```

- Postgresql (persistent storage used. k9s/pgsql-pv.yaml)
```
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl apply -f k8s/pgsql-pv.yaml
helm upgrade --install pg bitnami/postgresql --set persistence.existingClaim=postgresql-pv-claim --set volumePermissions.enabled=true
```

- Postgresql has been configured according to main document
```
kubectl port-forward --namespace default svc/pg-postgresql 5432:5432
export PGPASSWORD=$(kubectl get secret --namespace default pg-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)
psql --host 127.0.0.1 -U postgres -d postgres -p 5432 -tc "SELECT 1 FROM pg_database WHERE datname = 'space'" | grep -q 1 || psql --host 127.0.0.1 -U postgres -d postgres -p 5432 -c "CREATE DATABASE space"
PGHOST=localhost PGDATABASE=space PGUSER=postgres PGPASSWORD=$PGPASSWORD tern migrate -m ./migrations
```


# Secrets

Github repository secrets are used to store sensitive information

- GCP_CREDENTIALS
- GKE_PROJECT
- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN

# Pipeline workflow
Besides authentication and other helper steps, pipeline consists of following main steps
- Run unit tests
- Build docker image 
- Publish docker image (each new image is tagged with corresponding git commit hash)
- Deploy application into GKE

# Accessing booking-server application

- GCP load balancer public IP is 35.187.68.90
- host name is not configured for ingress, so it will serve content for IP or any host name alias
- use --insecure flag as tls is using self-signed certificate
```
curl --insecure --location --request GET 'https://35.187.68.90/v1/bookings' \               
--header 'Content-Type: application/json'
```


# Required improvements

- Use Kustomization or helm chart for k8s deployment, instead of just manifests and substituting environment variables
- Create dedicated folder under repository that holds k8s infrastructure related resource definitions, such as ingress controller and Postgresql resources. Create dedicated pipeline that will run only if that resources get changed and will deploy/update corresponding k8s infrastructure

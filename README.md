# Installation

## Quick install with Google Marketplace
Few clicks to install Harpocrates application to Google Kubernetes cluster using Google Marketplace.
Follow the [on-screen instructions](https://console.cloud.google.com/kubernetes/application/europe-north1-a/p1-harpocrates/harpocrates-ns/harpocrates?filter=solution-type:k8s&q=harpocrates&subtask=details&subtaskValue=privacy1-ab-public%2Fharpocrates&project=privacy1-ab-public&subtaskIndex=3)


## Command line instruction

### Set up command-lin tools

You need install below tools in your local workstation.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
-   [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Following the link [Tool Prerequisites](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/tool-prerequisites.md)
to install mpdev

### Configure gcloud as Docker credential helper
```
gcloud auth configure-docker
```

### Create cluster in project.
```
gcloud container clusters create "your_cluster_name" --zone "your_zone"
```

### Connect kubectl to cluster
```
gcloud container clusters get-credentials "your_cluster_name" --zone "your_zone"
```

### Clone this repo
```
git clone https://gitlab.com/privacy1/gcp-marketplace-harpocrates.git
```

### Config name and namespace environment variable
```
export NAMESPACE=harpocrates-ns
```

### Create namespace
```
kubectl create namespace "$NAMESPACE"
```

### Install Application resource definition
```
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

### Deploy APP container
```
scripts/deploy.sh <-l license_file> <-k key_file> <-c cert_file> <-s console domain name> <-p privacyfront domain name>
```

# Post installation

## Check app
```
kubectl get pod --namespace "${NAMESPACE}"
```

## Update license

When you buy the new license, you can update the license file. Copy the license file to /tmp/license

```
kubectl create configmap privacyone-license \
  --namespace ${NAMESPACE} \
  --from-file=license=/tmp/license \
  --dry-run -o yaml | kubectl apply -f -
```
Restart privacyfront service

```
kubectl scale statefulset privacyfront --replicas=0 --namespace ${NAMESPACE}
kubectl scale statefulset privacyfront --replicas=1 --namespace ${NAMESPACE}
```

## Backup database
Port forward to mysql database service.
```
kubectl port-forward --namespace ${NAMESPACE} harpocrates-mysql-0 33060:3306
```
Above command forward port 33060 to mysql service.

Run below command to backup harpocrates databases.
```
mysqldump -h 127.0.0.1 -P 33060 -u p1-user -p \
  --databases cerberusdb keychaindb ldardb keychainanalyticsdb dpiadb > ${db_backup_file}
```

## Restore database
```
mysql -h 127.0.0.1 --port=33060 -u p1-user -p < ${db_backup_file}
```

## Delete application
You can delete application by running
```
kubectl delete ${APP_NAME} --namespace ${NAMESPACE}
```
#!/usr/bin/env bash

set -xv
set -euo pipefail


GCP_PROJECT_ID=${GCP_PROJECT_ID:-}
COVERITY_CLUSTER_NAME=${COVERITY_CLUSTER_NAME:-}
COVERITY_CLUSTER_REGION=${COVERITY_CLUSTER_REGION:-}
COVERITY_NS=${COVERITY_NS:-}
COVERITY_PGHOST=${COVERITY_PGHOST:-}
COVERITY_PGPASSWORD=${COVERITY_PGPASSWORD:-}
COVERITY_GCS_BUCKET_NAME=${COVERITY_GCS_BUCKET_NAME:-"${COVERITY_NS}-uploads-bucket"}
COVERITY_GCS_SERVICE_ACCOUNT_FILE=${COVERITY_GCS_SERVICE_ACCOUNT_FILE:-}


echo -e "\n===> Deploying prerequisites for COVERITY-UMBRELLA Helm Chart...\n"
COVERITY_IMAGE_PULL_SECRET=${COVERITY_IMAGE_PULL_SECRET:-""}
COVERITY_LICENSE_SECRET_NAME=${COVERITY_LICENSE_SECRET_NAME:-"coverity-license"}
COVERITY_INITIALIZE_DB=${COVERITY_INITIALIZE_DB:-"true"}
COVERITY_PGPORT=${COVERITY_PGPORT:-"5432"}
COVERITY_PGUSER=${COVERITY_PGUSER:-"postgres"}
COVERITY_GCS_SA_SECRET_NAME="cnc-gcs-credentials"
COVERITY_GCS_SA_SECRET_KEY="key.json"


## Make sure your kubectl is pointing at the gcp cluster
gcloud container clusters get-credentials "${COVERITY_CLUSTER_NAME}" --region "${COVERITY_CLUSTER_REGION}" --project "${GCP_PROJECT_ID}"
kubectl config set-context $(kubectl config get-contexts | grep "^\*" | awk '{print $2}') --namespace "${COVERITY_NS}"
kubectl config get-contexts


kubectl create ns "${COVERITY_NS}" || true

# TODO create ingress tls secret
# $COVERITY_INGRESS_SECRET_NAME


kubectl create secret generic "${COVERITY_LICENSE_SECRET_NAME}" \
  --from-file=license.dat --namespace "${COVERITY_NS}" \
  --dry-run -o yaml | kubectl apply -f -

kubectl create secret generic "${COVERITY_GCS_SA_SECRET_NAME}" \
  --from-file=${COVERITY_GCS_SA_SECRET_KEY}="${COVERITY_GCS_SERVICE_ACCOUNT_FILE}" --namespace "${COVERITY_NS}" \
  --dry-run -o yaml | kubectl apply -f -


echo -e "\n===> Successfully installed prerequisites for COVERITY-UMBRELLA Helm Chart.\n"


echo -e "\n===> Deploying COVERITY-UMBRELLA Helm Chart...\n"
COVERITY_CIM_DATABASE="cim"
COVERITY_CIM_PGPASSWORD=$COVERITY_PGPASSWORD
COVERITY_CIM_PGUSER=$COVERITY_PGUSER
COVERITY_SCAN_DATABASE="scan-jobs-service"
COVERITY_STORAGE_DATABASE="storage-service"


helm upgrade "${COVERITY_NS}" --install \
   "${COVERITY_CHART}" \
   --debug \
   --wait \
   --timeout 15m0s \
   --namespace "${COVERITY_NS}" \
  --set imagePullSecret="${COVERITY_IMAGE_PULL_SECRET}" \
  --set licenseSecretName="${COVERITY_LICENSE_SECRET_NAME}" \
  --set postgres.user="${COVERITY_PGUSER}" \
  --set postgres.password="${COVERITY_PGPASSWORD}" \
  --set postgres.host="${COVERITY_PGHOST}" \
  --set postgres.port="${COVERITY_PGPORT}" \
  --set cim.postgres.password="${COVERITY_CIM_PGPASSWORD}" \
  --set cim.postgres.user="${COVERITY_CIM_PGUSER}" \
  --set cim.postgres.database=$COVERITY_CIM_DATABASE \
  --set "cim.initializeJob.enabled=$COVERITY_INITIALIZE_DB" \
  --set "cnc-storage-service.initializeJob.enabled=$COVERITY_INITIALIZE_DB" \
  --set "cnc-scan-service.initializeJob.enabled=$COVERITY_INITIALIZE_DB" \
  --set cnc-scan-service.postgres.database=$COVERITY_SCAN_DATABASE \
  --set cnc-storage-service.postgres.database=$COVERITY_STORAGE_DATABASE \
  --set cnc-storage-service.gcs.bucket="${COVERITY_GCS_BUCKET_NAME}" \
  --set cnc-storage-service.gcs.secret.name="${COVERITY_GCS_SA_SECRET_NAME}" \
  --set cnc-storage-service.gcs.secret.key="${COVERITY_GCS_SA_SECRET_KEY}" \
  --set cim.ingress.hosts={"${COVERITY_HOST}"} \
  --set cim.ingress.tls[0].secretName="cnc-ingress-tls" \
  --set cim.ingress.tls[0].hosts={"${COVERITY_HOST}"} \
  "$@"

echo -e "\n===> Successfully deployed COVERITY-UMBRELLA Helm Chart.\n"

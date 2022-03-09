#!/usr/bin/env bash

set -xv
set -euo pipefail

cat << EOF
This script is unsupported; it is provided only as a reference.
There are many ways to deploy Coverity; this merely demonstrates one possible method.
This helm deploy script is specific to infra deployed through this project.  It will not work with different infra.
If deploying to different infra, you will have to modify this script.
Users of this script must be familiar with the details of their infra in order to modify this script correctly.
Any modifications to this script will also not be supported.
EOF

# required variables:
# COVERITY_CLUSTER_NAME
# COVERITY_CLUSTER_REGION
# COVERITY_NS
# COVERITY_PGHOST
# COVERITY_PGPASSWORD
# COVERITY_S3_ACCESS_KEY
# COVERITY_S3_SECRET_KEY
# COVERITY_HOST
# COVERITY_CHART

echo -e "\n===> Deploying prerequisites for COVERITY-UMBRELLA Helm Chart...\n"
COVERITY_IMAGE_PULL_SECRET=${COVERITY_IMAGE_PULL_SECRET:-""}
COVERITY_LICENSE_SECRET_NAME=${COVERITY_LICENSE_SECRET_NAME:-"coverity-license"}
COVERITY_INITIALIZE_DB=${COVERITY_INITIALIZE_DB:-"true"}
COVERITY_PGPORT=${COVERITY_PGPORT:-"5432"}
COVERITY_PGUSER=${COVERITY_PGUSER:-"postgres"}
COVERITY_S3_BUCKET_REGION=${COVERITY_CLUSTER_REGION}
COVERITY_S3_BUCKET_NAME=${COVERITY_S3_BUCKET_NAME:-"${COVERITY_NS}-uploads-bucket"}
COVERITY_S3_SECRET_NAME="coverity-s3-credentials"
COVERITY_INGRESS_SECRET_NAME=${COVERITY_INGRESS_SECRET_NAME:-"coverity-ingress"}


## Fetch the cluster context and set default namespace
aws eks --region "${COVERITY_CLUSTER_REGION}" update-kubeconfig --name "${COVERITY_CLUSTER_NAME}"
kubectl config set-context $(kubectl config get-contexts | grep "^\*" | awk '{print $2}') --namespace "${COVERITY_NS}"
kubectl config get-contexts


kubectl create ns "${COVERITY_NS}" || true

# TODO create ingress tls secret
# $COVERITY_INGRESS_SECRET_NAME


kubectl create secret generic "${COVERITY_LICENSE_SECRET_NAME}" \
  --from-file=license.dat --namespace "${COVERITY_NS}" \
  --dry-run -o yaml | kubectl apply -f -

kubectl create secret generic "${COVERITY_S3_SECRET_NAME}" \
  --from-literal=aws_access_key="${COVERITY_S3_ACCESS_KEY}" \
  --from-literal=aws_secret_key="${COVERITY_S3_SECRET_KEY}" \
  --namespace "${COVERITY_NS}" \
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
   --set cnc-storage-service.s3.bucket="${COVERITY_S3_BUCKET_NAME}" \
   --set cnc-storage-service.s3.secret.name="${COVERITY_S3_SECRET_NAME}" \
   --set cnc-storage-service.s3.region="${COVERITY_S3_BUCKET_REGION}" \
   --set cim.ingress.hosts={"${COVERITY_HOST}"} \
   --set cim.ingress.tls[0].secretName="${COVERITY_INGRESS_SECRET_NAME}" \
   --set cim.ingress.tls[0].hosts={"${COVERITY_HOST}"} \
   -f values.yaml \
   "$@"

echo -e "\n===> Successfully deployed COVERITY-UMBRELLA Helm Chart.\n"

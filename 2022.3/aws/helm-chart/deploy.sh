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
COVERITY_S3_BUCKET_REGION=${COVERITY_CLUSTER_REGION}
COVERITY_S3_SECRET_NAME="coverity-s3-credentials"
COVERITY_INGRESS_SECRET_NAME="coverity-ingress"
COVERITY_LICENSE_SECRET_NAME="coverity-license"


## Fetch the cluster context and set default namespace
aws eks --region "${COVERITY_CLUSTER_REGION}" update-kubeconfig --name "${COVERITY_CLUSTER_NAME}"
kubectl config set-context $(kubectl config get-contexts | grep "^\*" | awk '{print $2}') --namespace "${COVERITY_NS}"
kubectl config get-contexts


kubectl create ns "${COVERITY_NS}" || true

kubectl create secret tls "$COVERITY_INGRESS_SECRET_NAME" \
  --namespace "$COVERITY_NS" \
  --cert=../../kubernetes/tls.crt \
  --key=../../kubernetes/tls.key \
  -o yaml --dry-run=client | kubectl apply -f -


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

helm upgrade "${COVERITY_NS}" "${COVERITY_CHART}" \
  --install \
  --version "${COVERITY_CHART_VERSION}" \
  --debug \
  --wait \
  --timeout 15m0s \
  --namespace "${COVERITY_NS}" \
  --set licenseSecretName="${COVERITY_LICENSE_SECRET_NAME}" \
  --set postgres.user="${COVERITY_PGUSER}" \
  --set postgres.password="${COVERITY_PGPASSWORD}" \
  --set postgres.host="${COVERITY_PGHOST}" \
  --set cnc-storage-service.s3.bucket="${COVERITY_S3_BUCKET_NAME}" \
  --set cnc-storage-service.s3.secret.name="${COVERITY_S3_SECRET_NAME}" \
  --set cnc-storage-service.s3.region="${COVERITY_S3_BUCKET_REGION}" \
  -f values.yaml \
  "$@"

echo -e "\n===> Successfully deployed COVERITY-UMBRELLA Helm Chart.\n"

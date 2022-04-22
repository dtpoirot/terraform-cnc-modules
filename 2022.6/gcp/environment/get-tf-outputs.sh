#!/bin/bash

echo "export COVERITY_CLUSTER_NAME=$(terraform output -raw gcp_cluster_name)"
echo "export COVERITY_CLUSTER_REGION=$(terraform output -raw gcp_cluster_region)"
echo "export COVERITY_GCS_BUCKET_NAME=$(terraform output -raw gcs_bucket_name)"
echo "export COVERITY_PGHOST=$(terraform output -raw db_instance_address)"
echo "export COVERITY_PGPASSWORD=$(terraform output -raw db_master_password)"
echo "export COVERITY_PGUSER=$(terraform output -raw db_instance_username)"
echo "export GCP_PROJECT_ID=$(terraform output -raw gcp_project_id)"

TMP_FILE=$(mktemp)
echo "$(terraform output -raw gcs_service_account)" > "${TMP_FILE}"
echo "export COVERITY_GCS_SERVICE_ACCOUNT_FILE=${TMP_FILE}"

echo "export COVERITY_CACHE_BUCKET_NAME=$(terraform output -raw coverity_cache_bucket_name)"
echo "export COVERITY_REDIS_HOST=$(terraform output -raw redis_host)"
echo "export COVERITY_REDIS_PORT=$(terraform output -raw redis_port)"
TMP_CA_FILE=$(mktemp)
echo "$(terraform output -raw redis_server_ca_cert)" > "${TMP_CA_FILE}"
echo "export COVERITY_REDIS_CA_CERT_FILE=${TMP_CA_FILE}"

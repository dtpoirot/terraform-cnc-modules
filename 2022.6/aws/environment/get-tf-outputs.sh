#!/bin/bash

echo "export COVERITY_CLUSTER_NAME=$(terraform output -raw cluster_name)"
echo "export COVERITY_CLUSTER_REGION=$(terraform output -raw cluster_region)"

echo "export COVERITY_PGHOST=$(terraform output -raw db_instance_address)"
echo "export COVERITY_PGPASSWORD=$(terraform output -raw db_master_password)"
echo "export COVERITY_PGPORT=$(terraform output -raw db_instance_port)"
echo "export COVERITY_PGUSER=$(terraform output -raw db_instance_username)"

echo "export COVERITY_S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)"
echo "export COVERITY_S3_BUCKET_REGION=$(terraform output -raw s3_bucket_region)"

echo "export COVERITY_CACHE_BUCKET_NAME=$(terraform output -raw coverity_cache_bucket_name)"
echo "export COVERITY_REDIS_HOST=$(terraform output -raw redis_host)"
echo "export COVERITY_REDIS_PORT=$(terraform output -raw redis_port)"
echo "export COVERITY_REDIS_PASSWORD=$(terraform output -raw redis_password)"
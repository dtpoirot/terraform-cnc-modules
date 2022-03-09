#!/bin/bash
echo "export CNC_CLUSTER_NAME=$(terraform output -raw aks_cluster_name)"
echo "export CNC_CLUSTER_REGION=$(terraform output -raw azure_resource_group_location)"
echo "export AZ_RESOURCE_GROUP=$(terraform output -raw azure_resource_group_name)"
echo "export CNC_PGHOST=$(terraform output -raw db_instance_address)"
echo "export CNC_PGUSER=$(terraform output -raw db_instance_username)"
echo "export CNC_PGPASSWORD=$(terraform output -raw db_master_password)"
echo "export CNC_AZ_BUCKET_NAME=$(terraform output -raw storage_bucket_name)"
echo "export CNC_AZ_STORAGE_ACCOUNT_NAME=$(terraform output -raw storage_account_name)"
echo "export CNC_AZ_STORAGE_ACCOUNT_KEY=$(terraform output -raw storage_access_key)"


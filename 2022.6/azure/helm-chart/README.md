# Deploy Coverity Helm chart

## Notes

This script is unsupported; it is provided only as a reference.
There are many ways to deploy Coverity; this merely demonstrates one possible method.
This helm deploy script is specific to infra deployed through this project.  It will not work with different infra.
If deploying to different infra, you will have to modify this script.
Users of this script must be familiar with the details of their infra in order to modify this script correctly.
Any modifications to this script will also not be supported.

## Steps

Set environment variables and run deploy script:
```bash
# these values come from your terraform output script
export COVERITY_CLUSTER_NAME=unique-prefix-cluster
export COVERITY_CLUSTER_REGION=???
export COVERITY_PGHOST=???
export COVERITY_PGUSER=postgres
export COVERITY_PGPASSWORD=???
export COVERITY_AZ_BUCKET_NAME=???
export COVERITY_AZ_STORAGE_ACCOUNT_NAME=???
export COVERITY_AZ_STORAGE_ACCOUNT_KEY=???
export COVERITY_CACHE_BUCKET_NAME=???
export COVERITY_REDIS_HOST=???
export COVERITY_REDIS_PORT=???
export COVERITY_REDIS_PASSWORD=???
export COVERITY_AZURE_ENDPOINT=???

## Get the additional env values
az account set --subscription="<set_subscription_id_passed_in_terraform_input>"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<set_subscription_id_passed_in_terraform_input>"
{
  "appId": "????",
  "displayName": "azure-cli-2022-04-20-17-42-16",
  "name": "????",
  "password": "???",
  "tenant": "???"
}
az role assignment create --role "Storage Blob Data Owner" --assignee <set_appId_value_from_above_cmd_output>

## Set additional env values
export COVERITY_NS=unique-prefix
export COVERITY_AZURE_TENANT_ID=<set_tenant_value_from_above_cmd_output>
export COVERITY_AZURE_CLIENT_ID=<set_appId_value_from_above_cmd_output>
export COVERITY_AZURE_CLIENT_SECRET=<set_password_value_from_above_cmd_output>
export COVERITY_AZURE_SUBSCRIPTION_ID=<set_subscription_id_passed_in_terraform_input>
export COVERITY_CHART_VERSION=??? 
export COVERITY_CHART=???
export COVERITY_LICENSE_PATH=path/to/license.dat


kubectl create ns $COVERITY_NS || true


./deploy.sh \
  --set imageRegistry=??? \
  --set publicImageRegistry=??? \
  --set imagePullSecret=??? \
  --set imageVersion=2022.6.0
```

**Note:** See the Coverity documentation for Helm parameters.

## Access UI

### Find the HOSTS and ADDRESS details

Get the host name and address from your ingress object:

```bash
$ kubectl get ingress -n $COVERITY_NS
NAME      CLASS    HOSTS                              ADDRESS         PORTS     AGE
???   <none>   ???   ???   80, 443   12m
```

### Update your /etc/hosts file

Using the IP address and host from the above steps, add this entry to your /etc/hosts file: (i.e. `sudo emacs /etc/hosts`)

```bash
???  ???
```

### Visit host in web browser

Open https://???:443 in your browser.

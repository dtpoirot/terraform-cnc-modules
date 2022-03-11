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
export COVERITY_PGPORT=5432
export COVERITY_PGUSER=postgres
export COVERITY_PGPASSWORD=???
export COVERITY_S3_BUCKET_NAME=???
export COVERITY_S3_BUCKET_REGION=???

## Set additional env values
export COVERITY_NS=unique-prefix
export COVERITY_S3_ACCESS_KEY=<set_access_key_passed_in_terraform_input>
export COVERITY_S3_SECRET_KEY=<set_secret_key_passed_in_terraform_input>
export COVERITY_CHART_VERSION=??? 
export COVERITY_CHART=???
export COVERITY_LICENSE_PATH=path/to/license.dat


kubectl create ns $COVERITY_NS || true


./deploy.sh \
  --set imageRegistry=??? \
  --set publicImageRegistry=??? \
  --set imagePullSecret=??? \
  --set imageVersion=2022.3.0
```

**Note:** See the Coverity documentation for Helm parameters.

## Access UI

### Find the HOSTS and ADDRESS details

Get the host name and address from your ingress object:

```bash
$ kubectl get ingress -n unique-prefix 
NAME      CLASS    HOSTS                              ADDRESS                                                                    PORTS     AGE
???   <none>   ???   ???.elb.amazonaws.com   80, 443   13m
```

### Ping the ADDRESS to get IP address

```
ping ???.elb.amazonaws.com
PING ???.elb.amazonaws.com (???): 56 data bytes
Request timeout for icmp_seq 0
Request timeout for icmp_seq 1
^C
--- ???.elb.amazonaws.com ping statistics ---
3 packets transmitted, 0 packets received, 100.0% packet loss
```

### Update your /etc/hosts file

Using the IP address and host from the above steps, add this entry to your /etc/hosts file: (i.e. `sudo emacs /etc/hosts`)

```bash
???  ???
```

### Visit host in web browser

Open https://???:443 in your browser.

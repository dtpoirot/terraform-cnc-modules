# Deploy Coverity Helm chart

Copy in a license:

```bash
cp path/to/license.dat .
```

Set environment variables:
```bash
# these values all come from your terraform output script
#   check the output to get the correct values
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
```

Run deploy script:
```bash
./deploy.sh
```

**Note:** See the Coverity documentation for Helm parameters.

## Access UI

### Find the HOSTS and ADDRESS details

Get the host name and address from your ingress object:

```bash
$ kubectl get ingress -n unique-prefix 
NAME      CLASS    HOSTS                              ADDRESS                                                                    PORTS     AGE
unique-prefix   <none>   ???   ???.elb.amazonaws.com   80, 443   13m
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

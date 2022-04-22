# Coverity on Kubernetes

Requirements:
 - a Kubernetes cluster -- 1.18 - 1.23
   - scripts are provided to create a single-node KinD cluster
   - at least one node with enough spare CPU and memory to run analysis
 - kubectl
 - helm3
 
You will also need:
 - a valid Coverity license
 - access to Coverity images
 - access to the Coverity helm chart
    
    ```bash
    helm repo add sig-repo https://sig-repo.synopsys.com/sig-cloudnative
    helm repo update
    helm search repo sig-repo/cnc
    ```
   
 - a valid tls.crt and tls.key
   (this example includes a self-signed certificate but you should supply your own certificate)

## What this includes

A script and configuration to set up a [KinD cluster](https://kind.sigs.k8s.io/).  
Only use this if you do not already have a Kubernetes cluster!
This script:
 - assumes you have Docker
 - creates a KinD cluster exposing ports 80 and 443
 - deploys an nginx ingress controller
 
A script and configuration to deploy Coverity and dependencies on any working Kubernetes cluster of the right version.
This script:
 - deploys a Postgres helm chart
 - deploys a Minio helm chart
 - creates secrets for your license and certficates
 - labels a node to enable Coverity analysis on that node
 - deploys the Coverity helm chart

## How this works

The Pure Kubernetes distribution depends solely on a Kubernetes cluster, and runs all dependencies inside that cluster.  This includes:

 - postgres – from a helm chart or operator
 - minio – for scanservices' idir storage
 - nginx ingress controller – for accessing CNC from outside the cluster

In order to run analysis pods, it labels a node so that CNC scan services will be able to use that node.

## Setup procedure

1. Get Coverity images into a registry that your kubernetes cluster can pull from

2. Copy your license file into this directory at `license.dat`

3. (optional) create a KinD cluster

    ```bash
    pushd kind
      ./create-cluster.sh
    popd
    ```

4. make sure your cluster can pull images from the registry

 - if authentication is required, you'll need to create an image pull secret and pass the name of the secret
   as a helm override, for example `--set imagePullSecret=registry-auth-secret-name`

5. run the deploy script, specifying the location of the chart as well as the location of the images and the name
   of a node to run analysis on:

    ```bash
    COVERITY_CHART_LOCATION=path/to/cnc \
    COVERITY_ANALYSIS_NODE_NAME=kind-control-plane \
      ./deploy-coverity.sh \
        --set imageRegistry=localhost:5000 \
        --set publicImageRegistry=localhost:5000 \
        --set imagePullSecret=registry-auth-secret-name
    ```

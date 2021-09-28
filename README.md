# localkube
Setup of local Kubernetes

## General usage

Run the script `create-cluster.sh [<cluster-name>]` - `<cluster-name>` defaults to `mykube`...
```
$ ./create-cluster.sh
```

## EOEPCA usage

Full setup script that performs:
* Install latest `k3d`
* Create the cluster with the default name `eoepca` (can be overridden)
* Deploy the nginx ingress controller
* Deploy the Cert Manager component
* Create the letsencrypt Cert Issuers
* Create PVC for login service
* Deploy the login service

Run the script `eoepca.sh [<cluster-name>]` - `<cluster-name>` defaults to `eoepca`...
```
$ ./create-cluster.sh
```

# myk8s

This project is not finished, please test at your own risk !

## Description

This is the instances + modules for Terraform to create a RKE cluster on Proxmox VMs



## How to start

### Requirements:

- Proxmox setup
- SSH Bastion setup
- pfSense or firewall configuration



### Steps

1. Copy the variables/secrets-example.tfvars to a new secrets folder in this repo (check .gitignore) - it's not commited
2. Change the details of:
   1. The secrets file you just copied
   2. The variable file you want to use



## Kubeconfig management


```
#Kubeconfig multi files setup
FILES="$HOME/.kube/clusters/*"
for f in $FILES
do
  echo "Processing $f kubeconfig file..."
  KCMERGE="$f:${KCMERGE}"
done 
unset KUBECONFIG
KUBECONFIG=$KCMERGE kubectl config view --merge --flatten > $HOME/.kube/config
chmod 600 $HOME/.kube/config
```

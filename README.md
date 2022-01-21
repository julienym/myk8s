# myk8s




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

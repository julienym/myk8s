

```
 ssh -i ~/.ssh/z600 ubuntu@tools-worker-0.tools.home "docker image ls --format '{{.Repository}}' | grep '^rancher/' | cut -d'/' -f2"



 echo "$masterRancher" "$workerRancher" | sort -u | tr '\n' ','
```


rancher/{coreos-flannel,fleet,fleet-agent,gitjob,hyperkube,mirrored-calico-cni,mirrored-calico-kube-controllers,mirrored-calico-node,mirrored-calico-pod2daemon-flexvol,mirrored-cluster-proportional-autoscaler,mirrored-coredns-coredns,mirrored-coreos-etcd,mirrored-metrics-server,mirrored-nginx-ingress-controller-defaultbackend,mirrored-pause,mirrored-pause rancher,nginx-ingress-controller,rancher-webhook,rke-tools,shell}







/home/julien/windows/.docker/certs.d/harbor.tools.home/ca.crt
+ restart docker desktop
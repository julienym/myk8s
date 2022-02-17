
rke_name = "dev"
domain_name = "dev"
api_domain = "api.dev.locacloud.com"

nodes = {
  masters = {
    count = 1
    cores = 2
    ram_mb = 4069
    bridge = "vmbr1"
    storage = "raid5"
    clone = "ubuntu-focal-template"
    name_prefix = "okd-master"
    macaddr = [
      "4E:A4:1B:51:42:34"
    ]
    roles = [
      "controlplane",
      "etcd"
    ]
  }
  workers = {
    count = 1
    cores = 4
    ram_mb = 8192
    bridge = "vmbr1"
    storage = "raid5"
    clone = "ubuntu-focal-template"
    name_prefix = "okd-worker"
    macaddr = [
      "02:A7:87:3B:63:E9"
    ]
    data_disk = []
    roles = [
      "worker"
    ]
  }
}

proxmox = {
    node_name = "iris"
    insecure = true
    # use_bastion = true
    ssh_private_key = "~/.ssh/z600"
}

okd_required_files = [
  "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/34.20211031.3.0/x86_64/fedora-coreos-34.20211031.3.0-live.x86_64.iso",
  "https://github.com/openshift/okd/releases/download/4.9.0-0.okd-2022-01-29-035536/openshift-install-linux-4.9.0-0.okd-2022-01-29-035536.tar.gz"
]

docker_images = [
  "quay.io/coreos/butane:release",
  "quay.io/coreos/coreos-installer:release",
  "quay.io/coreos/ignition-validate:release"
]

bastion = {
  # host = "bastion.pmx2.locacloud.com"
  # user = "ubuntu"
  ssh_private_key = "~/.ssh/id_rsa"
  ssh_public_key = "~/.ssh/id_rsa.pub"
}
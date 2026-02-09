network_gateway = "192.168.99.1"
network_mask    = "255.255.255.0"

pool_path = "/home/devops_course_libvirt_imgs"

vms_settings = {
  "master_0" = {
    hostname  = "master-0"
    cidr      = "192.168.99.100/24"
    cpu       = 3                       # cpu count
    mem       = 4 * 1024                # Megabytes
    disk_size = 40 * 1024 * 1024 * 1024 # Bytes
  },
  "worker_0" = {
    hostname  = "worker-0"
    cidr      = "192.168.99.101/24",
    cpu       = 1
    mem       = 1 * 1024
    disk_size = 20 * 1024 * 1024 * 1024
  },
  "worker_1" = {
    hostname  = "worker-1"
    cidr      = "192.168.99.102/24",
    cpu       = 1
    mem       = 1 * 1024
    disk_size = 20 * 1024 * 1024 * 1024
  },
}

# mkpasswd -m sha-512 --stdin
# root_pswd_hash = "<paste_here_sha512_and_uncomment> or set environment variable TF_VAR_root_pswd_hash='$6$S5MS0hXhr9peVYA.....'"

ssh_pubkey_path = "~/.ssh/id_ed25519.pub"

# "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
vm_image_url = "file:///var/lib/libvirt/isos/debian-13-generic-amd64.qcow2"

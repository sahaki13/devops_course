# VM network
resource "libvirt_network" "devops_course_network" {
  name      = "devops_course_network"
  autostart = true

  forward = {
    mode = "nat"
  }

  bridge = {
    name  = "virbr1_dcourse"
    stp   = "on"
    delay = "0"
  }

  ips = [
    {
      address = var.network_gateway
      netmask = var.network_mask
    }
  ]
}

# Disks pool
resource "libvirt_pool" "devops_course" {
  name = "devops_course"
  type = "dir"

  target = {
    path  = var.pool_path
    group = "0"
    owner = "0"
    mode  = "755"
  }
}

# Base image
resource "libvirt_volume" "base_image" {
  name = "debian_13_base.qcow2"
  pool = libvirt_pool.devops_course.name

  create = {
    content = {
        format = "qcow2"
        url    = var.vm_image_url
    }
  }
}

################################################################################

resource "libvirt_volume" "vm_filesystem_volume" {
  for_each = var.vms_settings

  name     = "${each.key}.qcow2"
  pool     = libvirt_pool.devops_course.name
  capacity = each.value.disk_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path   = libvirt_volume.base_image.path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  for_each = var.vms_settings

  name = "${each.key}_cloudinit"

  user_data = <<-EOF
    #cloud-config
    # https://cloudinit.readthedocs.io/en/latest/reference/
    # https://cloudinit.readthedocs.io/en/latest/howto/disable_cloud_init.html
    # https://cloudinit.readthedocs.io/en/latest/reference/yaml_examples/set_passwords.html

    manage_etc_hosts: false
    hostname: ${each.value.hostname}

    # Set passwords
    ssh_pwauth: true # allow ssh auth
    # disable_root: true
    chpasswd:
      expire: false
      users:
        - { name: root, password: ${var.root_pswd_hash} }
        - { name: debian, type: RANDOM }

    # Install some dependencies
    package_update: true
    package_upgrade: true
    packages:
      - openssh-server
      - curl
      - vim
      - htop
      - jq
      - tree
      - dnsutils
      # - nmap
      # - net-tools
      - qemu-guest-agent

    # Add SSH public key for key-based auth (more secure)
    ssh_authorized_keys:
      - ${file(var.ssh_pubkey_path)}

    # Set timezone
    timezone: Europe/Moscow

    # Set global envs
    write_files:
      - path: /etc/environment
        content: |
          export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
          export TERM=xterm-256color
        permissions: '0644'
        owner: root:root

    runcmd:
      - [ "systemctl", "enable", "--now", "qemu-guest-agent" ]
      - echo 'GRUB_CMDLINE_LINUX="cloud-init=disabled"' >> /etc/default/grub && update-grub2
      - echo "end $(date)" > /root/cloudinit.txt
      - cloud-init status --long >> /root/cloudinit.txt # /var/log/cloud-init.log, /var/log/cloud-init-output.log
      - touch /tmp/reboot_me

    power_state:
      mode: reboot
      message: Rebooting machine
      condition: test -f /tmp/reboot_me

  EOF

  meta_data = <<-EOF
    instance-id: ${each.value.hostname}
    local-hostname: ${each.value.hostname}
  EOF

  network_config = <<-EOF
    version: 2
    ethernets:
      enp1s0:
        addresses:
          - ${each.value.cidr}
        gateway4: ${var.network_gateway}
        nameservers:
          addresses: [ 8.8.8.8, 1.1.1.1 ]
        dhcp4: false
        dhcp6: false
  EOF
}

# Upload the cloud-init ISO into the pool
resource "libvirt_volume" "vm_cloudinit_volume" {
  for_each = var.vms_settings

  name = "${each.key}_cloudinit.iso"
  pool = libvirt_pool.devops_course.name

  create = {
    content = {
      url = libvirt_cloudinit_disk.vm_cloudinit[each.key].path
    }
  }
}

resource "libvirt_domain" "vm_domain" {
  for_each = var.vms_settings

  depends_on = [
    libvirt_volume.vm_filesystem_volume,
    libvirt_volume.vm_cloudinit_volume
  ]

  name        = "devops_course_${each.key}"
  memory      = each.value.mem
  memory_unit = "MiB"
  vcpu        = each.value.cpu
  type        = "kvm"

  cpu = {
    mode = "host-passthrough"
  }

  memory_backing = {
    memory_access = {
      mode = "shared"
    }
    memory_source = {
      type = "memfd"
    }
  }

  # Start the VM automatically
  running    = true

  # Boot configuration
  os = {
    # loader       = "/usr/share/OVMF/x64/OVMF_CODE.4m.fd"
    # kernel_args  = "console=ttyS0 root=/dev/vda1"
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot         = "hd"
  }

  features = {
    "acpi" = true,
    "apic" = {},
    "pae"  = true
  }

  metadata = {
    xml = file("metadata.xml")
  }

  # Attached disks
  devices = {
    channels = [
      {
        source = {
          unix = {}
        }
        target = {
          virt_io = {
            name = "org.qemu.guest_agent.0"
          }
        }
      }
    ]

    disks = [
      # Main system disk
      {
        source = {
          volume = {
            pool   = libvirt_pool.devops_course.name
            volume = libvirt_volume.vm_filesystem_volume[each.key].name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type    = "qcow2"
          # name    = "qemu"
          discard = "unmap"
        }
      },
      # Cloud-init config disk (will be detected automatically)
      {
        device = "cdrom"
        source = {
          volume = {
            pool   = libvirt_pool.devops_course.name
            volume = libvirt_volume.vm_cloudinit_volume[each.key].name
          }
        }
        target = {
          bus = "sata"
          dev = "sda"
        }
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = libvirt_network.devops_course_network.name
          }
          wait_for_ip = {
            timeout = 300     # seconds
            source  = "lease" # or "agent" or "any"
          }
        }
      }
    ]

    consoles = [
      {
        type = "pty"
        source = {
          path = "/dev/pts/0"
        }
        target = {
          type = "serial"
          # port omitted - let libvirt handle it
        }
      },
      {
        type = "pty"
        source = {
          path = "/dev/pts/1"
        }
        target = {
          type = "virtio"
          # port omitted - let libvirt handle it
        }
      },
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "127.0.0.1"
        }
      }
    ]
  }
}

# output "base_pool" {
#   value       = libvirt_pool.devops_course.name
#   description = "base pool"
# }

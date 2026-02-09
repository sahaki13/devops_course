terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      # version = "0.8.3"
      version = "0.9.2"
    }
  }
}

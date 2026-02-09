variable "ssh_pubkey_path" {
  type        = string
  description = "SSH Public key"
  sensitive   = true
}

variable "root_pswd_hash" {
  type        = string
  description = "Root pswd hash ( SHA-512 )"
  sensitive   = true
}

variable "vms_settings" {
  type = map(object({
    hostname  = string
    cidr      = string
    cpu       = number
    mem       = number
    disk_size = number
  }))
  description = "Virtual machines configuration"
}

variable "network_gateway" {
  type        = string
  description = "Net gw"
}

variable "network_mask" {
  type        = string
  description = "Net mask"
}

variable "pool_path" {
  type        = string
  description = "storage pool path"
}

variable "vm_image_url" {
  type        = string
  description = "Base image url"
}

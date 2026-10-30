variable "controller_host" {
  type        = string
  description = "Address of the Lenovo that is booted from the kcore installer ISO."
  default     = "192.168.40.107"
}

variable "os_disk" {
  type        = string
  description = "OS disk for the controller install. The NVMe that holds vg_kcore is not an install target."
  default     = "/dev/disk/by-id/ata-SAMSUNG_MZ7LN256HAJQ-000L7_S3S7NF0K818610"
}

variable "hostname" {
  type    = string
  default = "node-107"
}

variable "controller_105_host" {
  type        = string
  description = "Address of the second Lenovo, booted from the kcore installer ISO."
  default     = "192.168.40.105"
}

variable "os_disk_105" {
  type        = string
  description = "OS disk for the second controller. The Fanxiang NVMe that holds vg_kcore is not an install target."
  default     = "/dev/disk/by-id/ata-SAMSUNG_MZ7LN256HAJQ-000L7_S3S7NF0K805814"
}

variable "node_119_host" {
  type        = string
  description = "Address of the third Lenovo, booted from the kcore installer ISO."
  default     = "192.168.40.119"
}

variable "os_disk_119" {
  type        = string
  description = "OS disk for node-119. The Toshiba NVMe that holds vg_kcore is not an install target."
  default     = "/dev/disk/by-id/ata-Fanxiang_S101Q_256GB_AA00000000010384"
}

variable "cluster_name" {
  type    = string
  default = "lab"
}

variable "dashboard_listen_address" {
  type        = string
  description = "Controller web listener. Caddy owns TCP 9443, which is the Linksys forward from public 443, and proxies to this address."
  default     = "127.0.0.1:9444"
}

variable "dashboard_public_host" {
  type        = string
  description = "Public name on the Let's Encrypt certificate. TCP 443 for this name is forwarded to the node's port 9443."
  default     = "kcorehypervisor.tech"
}

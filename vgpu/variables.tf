variable "controller_address" {
  type    = string
  default = "192.168.40.107:9090"
}

variable "node_id" {
  type    = string
  default = "node-193"
}

variable "host_card" {
  type    = string
  default = "0000:61:00.0"
}

variable "guest_names" {
  type    = list(string)
  default = ["vgpu-01", "vgpu-02"]
}

variable "manager_url" {
  type    = string
  default = "http://192.168.40.10:18083/virtual-gpu-manager-8_v8.2/NVIDIA-Linux-x86_64-595.91.04-vgpu-kvm-aie.run"
}

variable "manager_sha256" {
  type    = string
  default = "2bc7f9be263d45a92331d781df33c14af1af01fcfa45e80102e80caf1ffaa74d"
}

variable "manager_file" {
  type    = string
  default = "NVIDIA-Linux-x86_64-595.91.04-vgpu-kvm-aie.run"
}

variable "manager_version" {
  type    = string
  default = "595.91.04"
}

variable "guest_driver_url" {
  type    = string
  default = "http://192.168.40.10:18083/guest-driver/vgpu-for-compute-guest-driver-8_v8.2/NVIDIA-Linux-x86_64-595.91.07-grid.run"
}

variable "guest_driver_sha256" {
  type    = string
  default = "ea76ddc36af14715758431e1b9dd3ef37f527267154e1d66ed6de1bde447e5d3"
}

variable "image_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "image_sha256" {
  type    = string
  default = "04e8f2461a16a44e78a370284471f29616cdd9baf1893df25807b71f985b6c94"
}

variable "phone_home_url" {
  type        = string
  default     = "http://192.168.40.10:18083/phone-home"
  description = "Guest cloud-init appends the hostname and nvidia-smi -L output to this URL."
}

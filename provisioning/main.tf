terraform {
  required_version = ">= 1.5"
  required_providers {
    kcore = {
      source  = "kcorehypervisor/kcore"
      version = ">= 0.5.1"
    }
  }
}

provider "kcore" {
  controller_address   = var.controller_address
  tls_cert_path        = "${path.module}/../certs/kctl.crt"
  tls_key_path         = "${path.module}/../certs/kctl.key"
  tls_ca_path          = "${path.module}/../certs/ca.crt"
  provisioning_address = var.provisioning_address
}

variable "controller_address" {
  type    = string
  default = "192.168.40.107:9090"
}

variable "provisioning_address" {
  type    = string
  default = "127.0.0.1:9091"
}

locals {
  # Init path from the substituters installer netboot tree. GRUB appends
  # these as kernel arguments. The copied kernel-params file is not read.
  dell_boot_params = {
    init     = "/nix/store/lfz697hgqg59ifviszr2w1f2czbnalhb-nixos-system-kvm-node-kcoreOS/init"
    loglevel = "4"
    lsm      = "landlock,yama,bpf"
  }
  grub_http_boot_url = "http://192.168.40.10:8081/boot/efi/x86_64/grub.efi"
}

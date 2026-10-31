terraform {
  required_version = ">= 1.5"
  required_providers {
    kcore = {
      source  = "kcorehypervisor/kcore"
      version = ">= 0.5.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

provider "kcore" {
  controller_address = var.controller_address
  tls_cert_path      = "${path.module}/../certs/kctl.crt"
  tls_key_path       = "${path.module}/../certs/kctl.key"
  tls_ca_path        = "${path.module}/../certs/ca.crt"
}

resource "tls_private_key" "vgpu" {
  algorithm = "ED25519"
}

resource "kcore_ssh_key" "vgpu" {
  name       = "vgpu-lab"
  public_key = tls_private_key.vgpu.public_key_openssh
}

resource "kcore_vgpu_host" "a2" {
  node_id         = var.node_id
  host_cards      = [var.host_card]
  num_vfs         = 0
  manager_url     = var.manager_url
  manager_sha256  = var.manager_sha256
  manager_file    = var.manager_file
  manager_version = var.manager_version
  reboot          = true

  timeouts {
    create = "45m"
  }
}

data "kcore_gpus" "node" {
  node_id = var.node_id

  depends_on = [kcore_vgpu_host.a2]
}

resource "kcore_vm" "guest" {
  for_each = toset(var.guest_names)

  name               = each.key
  cpu                = 4
  memory_bytes       = 8 * 1024 * 1024 * 1024
  storage_backend    = "filesystem"
  storage_size_bytes = 40 * 1024 * 1024 * 1024
  target_node        = var.node_id
  image_url          = var.image_url
  image_sha256       = var.image_sha256
  image_format       = "qcow2"
  desired_state      = "running"
  ssh_key_names      = [kcore_ssh_key.vgpu.name]
  vgpus              = ["A2-4C"]

  nic {
    network = "default"
  }

  cloud_init_user_data = templatefile("${path.module}/guest-init.yaml.tftpl", {
    guest_driver_url    = var.guest_driver_url
    guest_driver_sha256 = var.guest_driver_sha256
    phone_home          = var.phone_home_url
    hostname            = each.key
  })

  depends_on = [kcore_vgpu_host.a2]

  timeouts {
    create = "45m"
  }
}

locals {
  certs_dir          = "${path.module}/certs"
  controller_address = "${var.controller_host}:9090"
  tls_ready = (
    fileexists("${local.certs_dir}/kctl.crt")
    && fileexists("${local.certs_dir}/kctl.key")
    && fileexists("${local.certs_dir}/ca.crt")
  )
}

terraform {
  required_version = ">= 1.5"
  required_providers {
    kcore = {
      source  = "kcorehypervisor/kcore"
      version = ">= 0.5.1"
    }
  }
}

# The first apply creates certs/ and then installs the node. Until those
# files exist the provider dials without a client certificate. Later applies
# use the kctl certificate this cluster resource writes.
provider "kcore" {
  controller_address = local.controller_address
  tls_cert_path      = local.tls_ready ? "${local.certs_dir}/kctl.crt" : ""
  tls_key_path       = local.tls_ready ? "${local.certs_dir}/kctl.key" : ""
  tls_ca_path        = local.tls_ready ? "${local.certs_dir}/ca.crt" : ""
}

resource "kcore_cluster" "lab" {
  name       = var.cluster_name
  controller = local.controller_address
  certs_dir  = local.certs_dir
}

resource "kcore_node" "controller" {
  bootstrap      = true
  address        = "${var.controller_host}:9091"
  os_disk        = var.os_disk
  certs_dir      = kcore_cluster.lab.certs_dir
  run_controller = true
  hostname       = var.hostname
  node_id        = var.hostname
  insecure       = true

  timeouts {
    create = "120m"
  }
}

resource "kcore_node" "controller_105" {
  address         = "${var.controller_105_host}:9091"
  os_disk         = var.os_disk_105
  certs_dir       = kcore_cluster.lab.certs_dir
  run_controller  = true
  join_controller = kcore_node.controller.controller_address
  hostname        = "node-105"
  node_id         = "node-105"
  insecure        = true

  timeouts {
    create = "120m"
  }
}

# Agent-only Lenovo. OS on the Fanxiang SATA SSD; Toshiba NVMe (vg_kcore,
# including kcore-win10-01) is not passed as a data disk and is left alone.
resource "kcore_node" "node_119" {
  address         = "${var.node_119_host}:9091"
  os_disk         = var.os_disk_119
  certs_dir       = kcore_cluster.lab.certs_dir
  join_controller = kcore_node.controller.controller_address
  hostname        = "node-119"
  node_id         = "node-119"
  insecure        = true

  timeouts {
    create = "120m"
  }
}

# The provider installs the controller but has no dashboard resource. The UI
# is enabled by the NixOS module on the controller (services.kcore.dashboard).
# Changing dashboard_listen_address replaces this resource and switches the node.
resource "terraform_data" "dashboard" {
  depends_on = [kcore_node.controller]

  input = {
    host        = var.controller_host
    listen      = var.dashboard_listen_address
    public_host = var.dashboard_public_host
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/enable-dashboard.sh ${self.input.host} ${self.input.listen} ${self.input.public_host}"
  }
}

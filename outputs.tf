output "controller_address" {
  value = kcore_node.controller.controller_address
}

output "controller_105_address" {
  value = kcore_node.controller_105.controller_address
}

output "kctl_cert" {
  value = kcore_cluster.lab.client_cert_path
}

output "ca_cert" {
  value = kcore_cluster.lab.ca_cert_path
}

output "dashboard_url" {
  value = "https://${var.dashboard_public_host}/"
}

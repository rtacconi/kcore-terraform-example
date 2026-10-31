output "vgpu_slices" {
  value = {
    for name, vm in kcore_vm.guest : name => vm.vgpu_slices
  }
}

output "gpu_inventory" {
  value = data.kcore_gpus.node.devices
}

output "ssh_private_key" {
  value     = tls_private_key.vgpu.private_key_openssh
  sensitive = true
}

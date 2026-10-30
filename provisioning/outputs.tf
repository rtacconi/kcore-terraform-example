output "latest_iso_id" {
  value = kcore_image.installer.id
}

output "latest_iso_name" {
  value = kcore_image.installer.name
}

output "latest_iso_sha256" {
  value = kcore_image.installer.sha256
}

output "dell_machine_ids" {
  value = {
    cnws30004500ug = kcore_machine.dell_cnws30004500ug.id
    cnws30011r00bw = kcore_machine.dell_cnws30011r00bw.id
    cnws30096e00m6 = kcore_machine.dell_cnws30096e00m6.id
  }
}

# .21 already has UEFI HTTP boot enabled on the cabled NIC. Set the
# one-time HTTP target, then power on. A BIOS settings job clears a
# boot override, so this stays after the image artifacts exist.
resource "kcore_bmc_boot" "dell_cnws30011r00bw" {
  machine_id = kcore_machine.dell_cnws30011r00bw.id
  boot_url   = local.grub_http_boot_url

  depends_on = [kcore_machine_config.dell_cnws30011r00bw]
}

resource "kcore_power_action" "dell_cnws30011r00bw_on" {
  machine_id = kcore_machine.dell_cnws30011r00bw.id
  action     = "on"
  wait       = true

  depends_on = [kcore_bmc_boot.dell_cnws30011r00bw]
}

# Host Embedded.2 reported no link while Embedded.1 was at 1 Gbps. HTTP boot
# was pinned to Embedded.2, so move it and reboot for the BIOS job. The job
# clears the one-time HTTP override; that override is set again afterwards.
resource "terraform_data" "dell_cnws30011r00bw_http_nic" {
  input = "NIC.Embedded.1-1-1"

  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/set-http-nic.py 192.168.40.21 ${self.input}"
  }

  depends_on = [kcore_bmc_boot.dell_cnws30011r00bw]
}

resource "kcore_power_action" "dell_cnws30011r00bw_bios" {
  machine_id = kcore_machine.dell_cnws30011r00bw.id
  action     = "cycle"

  depends_on = [terraform_data.dell_cnws30011r00bw_http_nic]
}

# .20 HTTP boot is enabled on NIC.Embedded.1, which has link. iDRAC 4.10
# rejects GracefulRestart, so the restart uses ForceRestart.
resource "kcore_power_action" "dell_cnws30004500ug_on" {
  machine_id = kcore_machine.dell_cnws30004500ug.id
  action     = "on"
  wait       = true

  depends_on = [kcore_machine_config.dell_cnws30004500ug]
}

resource "kcore_bmc_boot" "dell_cnws30004500ug" {
  machine_id = kcore_machine.dell_cnws30004500ug.id
  boot_url   = local.grub_http_boot_url

  depends_on = [kcore_machine_config.dell_cnws30004500ug]
}

resource "kcore_power_action" "dell_cnws30004500ug_http" {
  machine_id = kcore_machine.dell_cnws30004500ug.id
  action     = "cycle"
  force      = true

  depends_on = [kcore_bmc_boot.dell_cnws30004500ug]
}

# .22 HTTP boot is already on NIC.Embedded.2, which is the cabled LOM
# (Embedded.1 is LinkDown). Same power + one-time HTTP override path as .20.
resource "kcore_power_action" "dell_cnws30096e00m6_on" {
  machine_id = kcore_machine.dell_cnws30096e00m6.id
  action     = "on"
  wait       = true

  depends_on = [kcore_machine_config.dell_cnws30096e00m6]
}

resource "kcore_bmc_boot" "dell_cnws30096e00m6" {
  machine_id = kcore_machine.dell_cnws30096e00m6.id
  boot_url   = local.grub_http_boot_url

  depends_on = [kcore_machine_config.dell_cnws30096e00m6]
}

resource "kcore_power_action" "dell_cnws30096e00m6_http" {
  machine_id = kcore_machine.dell_cnws30096e00m6.id
  action     = "cycle"

  depends_on = [kcore_bmc_boot.dell_cnws30096e00m6]
}

resource "kcore_machine" "dell_cnws30004500ug" {
  name          = "dell-inc.-cnws30004500ug"
  mac_address   = "2C:EA:7F:D7:95:05"
  ip_address    = "192.168.40.20"
  manufacturer  = "Dell Inc."
  model         = "PowerEdge T140"
  serial_number = "CNWS30004500UG"

  lifecycle {
    prevent_destroy = true
  }
}

resource "kcore_machine_config" "dell_cnws30004500ug" {
  machine_id  = kcore_machine.dell_cnws30004500ug.id
  image_id    = kcore_image.installer.id
  boot_params = local.dell_boot_params

  lifecycle {
    prevent_destroy = true
  }
}

resource "kcore_machine" "dell_cnws30011r00bw" {
  name          = "dell-inc.-cnws30011r00bw"
  mac_address   = "B8:CB:29:B2:B8:59"
  ip_address    = "192.168.40.21"
  manufacturer  = "Dell Inc."
  model         = "PowerEdge T140"
  serial_number = "CNWS30011R00BW"

  lifecycle {
    prevent_destroy = true
  }
}

resource "kcore_machine_config" "dell_cnws30011r00bw" {
  machine_id  = kcore_machine.dell_cnws30011r00bw.id
  image_id    = kcore_image.installer.id
  boot_params = local.dell_boot_params

  lifecycle {
    prevent_destroy = true
  }
}

resource "kcore_machine" "dell_cnws30096e00m6" {
  name          = "dell-inc.-cnws30096e00m6"
  mac_address   = "6C:2B:59:9B:51:CB"
  ip_address    = "192.168.40.22"
  manufacturer  = "Dell Inc."
  model         = "PowerEdge T140"
  serial_number = "CNWS30096E00M6"

  lifecycle {
    prevent_destroy = true
  }
}

resource "kcore_machine_config" "dell_cnws30096e00m6" {
  machine_id  = kcore_machine.dell_cnws30096e00m6.id
  image_id    = kcore_image.installer.id
  boot_params = local.dell_boot_params

  lifecycle {
    prevent_destroy = true
  }
}

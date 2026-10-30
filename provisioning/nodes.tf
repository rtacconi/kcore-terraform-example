# Live installer addresses. These are DHCP addresses of the netbooted
# system, not the iDRAC addresses. Each OS disk is the empty SATA SSD.
# The Micron disks are Ceph OSDs and are not install targets.
resource "kcore_node" "dell_20" {
  address         = "192.168.40.103:9091"
  os_disk         = "/dev/disk/by-id/ata-INTEL_SSDSC2BB300G4_BTWL4220020V300PGN"
  certs_dir       = "${path.module}/../certs"
  join_controller = var.controller_address
  hostname        = "dell-20"
  node_id         = "dell-20"
  insecure        = true

  timeouts {
    create = "120m"
  }
}

resource "kcore_node" "dell_21" {
  address         = "192.168.40.143:9091"
  os_disk         = "/dev/disk/by-id/ata-Fanxiang_S101_128GB_26081157635001512"
  certs_dir       = "${path.module}/../certs"
  join_controller = var.controller_address
  hostname        = "dell-21"
  node_id         = "dell-21"
  insecure        = true

  depends_on = [kcore_node.dell_20]

  timeouts {
    create = "120m"
  }
}

# iDRAC 192.168.40.22 / CNWS30096E00M6. Live installer is on eno2 (Embedded.2).
resource "kcore_node" "dell_22" {
  address         = "192.168.40.145:9091"
  os_disk         = "/dev/disk/by-id/ata-Fanxiang_S101_128GB_26081157635001197"
  certs_dir       = "${path.module}/../certs"
  join_controller = var.controller_address
  hostname        = "dell-22"
  node_id         = "dell-22"
  insecure        = true

  depends_on = [kcore_node.dell_21]

  timeouts {
    create = "120m"
  }
}

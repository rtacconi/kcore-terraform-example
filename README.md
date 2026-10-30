# kcore Terraform example

Creates a new cluster trust root and installs that cluster's controller onto the Lenovo booted from the kcore installer ISO.

The apply wipes the Samsung SSD (`ata-SAMSUNG_MZ7LN256HAJQ-000L7_S3S7NF0K818610`) and reboots into the installed system. The SSSTC NVMe (`vg_kcore`, the existing VM volumes) is not passed as a data disk, so it is left in place.

```sh
export TF_CLI_CONFIG_FILE="$PWD/terraform.rc"
./bin/terraform init
./bin/terraform apply
```

`terraform.rc` points Terraform at the provider binary in `provider/`. Cluster keys are written to `certs/` (mode 0600). After the controller is up, `kctl` can use `certs/kctl.crt`, `certs/kctl.key`, and `certs/ca.crt` against `192.168.40.107:9090`.

The live installer has no local login. SSH to it before the reboot is `root` / `kcore`. The installed system keeps that root password until it is changed.

`terraform_data.dashboard` turns on the web UI after the controller is installed. The provider has no dashboard resource: the UI is `services.kcore.dashboard` on the node, and the apply switches that NixOS option. The controller listens on `dashboard_listen_address` (default `127.0.0.1:9444`). Caddy listens on TCP 9443, obtains a Let's Encrypt certificate for `dashboard_public_host`, and proxies to the controller. The Linksys forward stays public 443 to port 9443. Sign-in still needs an operator password; `kcore_operator` creates the user and client certificate, not that password.

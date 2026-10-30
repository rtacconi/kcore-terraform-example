# Fixed installer from the substituters branch. The earlier 20261029 store
# ISO still builds with --offline and cannot fetch nixpkgs during install.
# netboot_tree is published by DownloadImage into artifacts_dir/images/<id>/.
resource "kcore_image" "installer" {
  name         = "kcoreos-0.6.1-substituters-20261029"
  version      = "0.6.1"
  architecture = "x86_64"
  image_type   = "iso"
  source_url   = "http://127.0.0.1:18082/nixos-kcoreOS-x86_64-linux.iso"
  sha256       = "80299f6f6a0b2a57ad4bb78fc0357f15e6c5b6c3264270904a4a942b7443a090"
  download     = true
  verify       = true

  metadata = {
    netboot_tree = "/nix/store/018wr1q0kv7r39dmdmniq7vld0ccr8l1-kcore-netboot-tree"
  }

  timeouts {
    create = "60m"
  }
}

#!/usr/bin/env bash
# Point the installed controller at the 0.6.1 dashboard and switch the system.
# The kcore provider has no dashboard resource. The web UI is a NixOS option
# on the controller unit (KCORE_WEB_ENABLED, listen address, UI directory).
set -euo pipefail

host="${1:?controller host}"
listen="${2:?listen address}"
public_host="${3:?public host}"
case "$listen" in
  *:*) ;;
  *) echo "dashboard listen address must be host:port, got $listen" >&2; exit 1 ;;
esac
case "$public_host" in
  *[!A-Za-z0-9.-]* | "" ) echo "public host must be a DNS name, got $public_host" >&2; exit 1 ;;
esac

sshpass_bin=""
if [[ -x /nix/store/xwpbf4n3ljnm9rspfhysvr2qvvkgpwdg-sshpass-1.10/bin/sshpass ]]; then
  sshpass_bin=/nix/store/xwpbf4n3ljnm9rspfhysvr2qvvkgpwdg-sshpass-1.10/bin/sshpass
elif command -v sshpass >/dev/null 2>&1; then
  sshpass_bin="$(command -v sshpass)"
else
  sshpass_bin="$(find /nix/store -maxdepth 1 -type d -name '*-sshpass-*' -exec test -x '{}/bin/sshpass' \; -print -quit)/bin/sshpass"
fi

export SSHPASS=kcore
exec "$sshpass_bin" -e ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  "root@${host}" \
  env LISTEN="$listen" PUBLIC_HOST="$public_host" bash -s <<'REMOTE'
set -euo pipefail
dash=/nix/store/9bznz951kdjx92c3zfgw2p9hqgz9r1r4-kcore-dashboard-0.6.1
src_name=cqwb6a0h07l47bgri0iip3wvg308va87-pcf9glird7jkfm5xh7fq4ani3y6kdhk6-source
flake=/etc/nixos/flake.nix

if [[ ! -d "$dash/share/kcore-dashboard" ]]; then
  echo "dashboard package is not on this node: $dash" >&2
  exit 1
fi

current="$(systemctl show kcore-controller -p Environment --value || true)"
if [[ "$current" == *"KCORE_WEB_ENABLED=true"* && "$current" == *"KCORE_WEB_LISTEN_ADDR=${LISTEN}"* ]] && grep -q 'kcore-public-tls' "$flake" && systemctl is-active --quiet caddy; then
  echo "dashboard already listening on ${LISTEN} behind caddy"
  exit 0
fi
if grep -q 'kcore-public-tls' "$flake" && [[ "$LISTEN" == *:9443 ]]; then
  echo "caddy owns TCP 9443; choose another dashboard listen address" >&2
  exit 1
fi

if [[ ! -d /nix/store/$src_name ]]; then
  if ! findmnt /mnt/iso >/dev/null; then
    mkdir -p /mnt/iso
    mount -o ro /dev/disk/by-label/KCORE /mnt/iso
  fi
  if ! findmnt /mnt/squash >/dev/null; then
    mkdir -p /mnt/squash
    mount -o ro /mnt/iso/nix-store.squashfs /mnt/squash
  fi
  added="$(nix-store --add "/mnt/squash/$src_name")"
  sed -i "s|kcoreSrc = /nix/store/${src_name};|kcoreSrc = ${added};|" "$flake"
fi

python_line="            services.kcore.dashboard.enable = true;"
if grep -q 'services.kcore.dashboard.enable = nixpkgs.lib.mkForce false;' "$flake"; then
  sed -i "s|services.kcore.dashboard.enable = nixpkgs.lib.mkForce false;|services.kcore.dashboard.enable = true;\n            services.kcore.dashboard.listenAddress = \"${LISTEN}\";\n            services.kcore.dashboard.package = pin \"kcore-dashboard-0.6.1\" ${dash};|" "$flake"
elif grep -q 'services.kcore.dashboard.listenAddress' "$flake"; then
  sed -i "s|services.kcore.dashboard.listenAddress = \"[^\"]*\";|services.kcore.dashboard.listenAddress = \"${LISTEN}\";|" "$flake"
  if ! grep -q 'services.kcore.dashboard.openFirewall' "$flake"; then
    sed -i "/services.kcore.dashboard.listenAddress/a\\            services.kcore.dashboard.openFirewall = false;" "$flake"
  fi
else
  echo "flake.nix has no dashboard settings to update" >&2
  exit 1
fi

if ! grep -q 'kcore-public-tls' "$flake"; then
  cat > /tmp/kcore-caddy.nix <<EOF
            # kcore-public-tls: Linksys forwards public TCP 443 to :9443.
            services.caddy.enable = true;
            services.caddy.openFirewall = false;
            services.caddy.logFormat = "level INFO";
            services.caddy.globalConfig = ''
              http_port 9080
              https_port 9443
              auto_https disable_redirects
              servers {
                protocols h1 h2
              }
            '';
            services.caddy.virtualHosts."${PUBLIC_HOST}".extraConfig = ''
              tls {
                issuer acme {
                  disable_http_challenge
                  alt_tlsalpn_port 9443
                }
              }
              reverse_proxy https://127.0.0.1:9444 {
                transport http {
                  tls_insecure_skip_verify
                }
              }
            '';
            systemd.services.caddy.after = [ "kcore-controller.service" ];
EOF
  awk '
    { print }
    /services\.kcore\.kctl\.package/ && !inserted {
      while ((getline line < "/tmp/kcore-caddy.nix") > 0) print line
      inserted = 1
    }
    END { if (!inserted) exit 1 }
  ' "$flake" > "${flake}.new"
  mv "${flake}.new" "$flake"
fi

# The installed store rehashed the ISO packages. Point the flake at the copies
# the booted generation is already running.
fix_pin() {
  local old="$1" new="$2"
  if [[ ! -d "$old" && -d "$new" ]]; then
    sed -i "s|${old}|${new}|" "$flake"
  fi
}
fix_pin /nix/store/a98pl538d0kl9ngcy9a1m1kxm00nqlas-kcore-node-agent-0.6.1 /nix/store/3v2c1n3h01rgvyzzglp7hbsg8zb44lq6-kcore-node-agent-0.6.1
fix_pin /nix/store/cyc4vjqd2x7maggxm191rv3gy6jx2fnc-kcore-controller-0.6.1 /nix/store/3667xjdx1k5q7dbd3i5fbxgrb18949sg-kcore-controller-0.6.1
fix_pin /nix/store/xkf78vpd6kdm8g2pyhmyg2783kdqsafd-kcore-console-0.6.1 /nix/store/rjrw06p7dkskz23pda64swpciy8svjbf-kcore-console-0.6.1
fix_pin /nix/store/mdsiy7zjrpqkfvvg0i1h6d6dns3y21mj-kctl-0.6.1 /nix/store/vkvy3m7pxqrdsvjnzs325qhyw0ykmfb9-kctl-0.6.1

nixos-rebuild switch --flake /etc/nixos#kcore --impure --no-write-lock-file
systemctl is-active kcore-controller
REMOTE

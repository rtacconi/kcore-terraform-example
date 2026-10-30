#!/usr/bin/env python3
"""Stage Dell HttpDev1 onto a cabled LOM and queue a BIOS job.

The password is read from the provisioning .env. It is not printed and it is
not passed on the command line. A BIOS job clears a one-time boot override,
so this also clears that override before the reboot that applies the job.
"""

import json
import ssl
import sys
import urllib.error
import urllib.request
from pathlib import Path

ENV_PATH = Path("/mnt/data/dev/kcore/kcore-provisioning/.env")
GRUB_URI = "http://192.168.40.10:8081/boot/efi/x86_64/grub.efi"


def load_env(path: Path) -> dict[str, str]:
    env: dict[str, str] = {}
    for line in path.read_text().splitlines():
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def call(opener, method: str, url: str, body: dict | None = None) -> tuple[int, dict]:
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={"Accept": "application/json", "Content-Type": "application/json"},
    )
    try:
        with opener.open(req, timeout=30) as resp:
            raw = resp.read().decode()
            return resp.status, json.loads(raw) if raw else {}
    except urllib.error.HTTPError as err:
        raw = err.read().decode()
        try:
            payload = json.loads(raw) if raw else {}
        except json.JSONDecodeError:
            payload = {"message": raw[:200]}
        return err.code, payload


def message_id(payload: dict) -> str:
    info = payload.get("error", {}).get("@Message.ExtendedInfo") or payload.get("@Message.ExtendedInfo") or []
    if info and isinstance(info, list):
        return str(info[0].get("MessageId") or info[0].get("Message") or "")
    return str(payload.get("Id") or payload.get("JobState") or "")


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: set-http-nic.py <bmc-ip> <nic-id>", file=sys.stderr)
        return 2
    ip, iface = sys.argv[1], sys.argv[2]
    env = load_env(ENV_PATH)
    user, password = env["BMC_USER"], env["BMC_PASSWORD"]
    ctx = ssl._create_unverified_context()
    mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
    mgr.add_password(None, f"https://{ip}", user, password)
    opener = urllib.request.build_opener(
        urllib.request.HTTPSHandler(context=ctx),
        urllib.request.HTTPBasicAuthHandler(mgr),
    )
    base = f"https://{ip}"

    status, jobs = call(opener, "GET", f"{base}/redfish/v1/Managers/iDRAC.Embedded.1/Jobs")
    if status < 300:
        for member in jobs.get("Members") or []:
            job_url = member.get("@odata.id")
            if not job_url:
                continue
            job_status, job = call(opener, "GET", f"{base}{job_url}")
            if job_status >= 300:
                continue
            if job.get("JobType") == "BIOSConfiguration" and job.get("JobState") == "Scheduled":
                print(f"bios_job_pending {job.get('Id')}")
                return 0

    status, payload = call(
        opener,
        "PATCH",
        f"{base}/redfish/v1/Systems/System.Embedded.1",
        {"Boot": {"BootSourceOverrideEnabled": "Disabled", "BootSourceOverrideTarget": "None"}},
    )
    print(f"clear_override {status} {message_id(payload)}")
    if status >= 300:
        return 1

    status, payload = call(
        opener,
        "PATCH",
        f"{base}/redfish/v1/Systems/System.Embedded.1/Bios/Settings",
        {
            "@Redfish.SettingsApplyTime": {"ApplyTime": "OnReset"},
            "Attributes": {
                "HttpDev1EnDis": "Enabled",
                "HttpDev1Interface": iface,
                "HttpDev1Uri": GRUB_URI,
                "HttpDev1TlsMode": "None",
            },
        },
    )
    print(f"bios_patch {status} {message_id(payload)}")
    if status >= 300:
        return 1

    status, payload = call(
        opener,
        "POST",
        f"{base}/redfish/v1/Managers/iDRAC.Embedded.1/Jobs",
        {"TargetSettingsURI": "/redfish/v1/Systems/System.Embedded.1/Bios/Settings"},
    )
    print(f"bios_job {status} {message_id(payload)}")
    if status >= 300:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

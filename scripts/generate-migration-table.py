#!/usr/bin/env python3
"""Generate docs/migration-table.md from a checkout of alarm-aurora.

Reads packages/*/PKGBUILD (pkgname, pkgver, pkgdesc, license, build system
hints) and sources.json (the shared version/commit/sha256 pins) and emits a
Markdown table. It never executes a PKGBUILD and never downloads anything.

Usage:
    python3 scripts/generate-migration-table.py /path/to/alarm-aurora
    python3 scripts/generate-migration-table.py /tmp/alarm-aurora > docs/migration-table.md
"""
import json
import re
import sys
from pathlib import Path


def _first(pattern, text):
    m = re.search(pattern, text, re.M)
    return m.group(1).strip().strip("'\"") if m else ""


def _names(text):
    # pkgname=foo  or  pkgname=('a' 'b')  or  pkgname=("$pkgbase" ...)
    m = re.search(r"^pkgname=\(?([^)\n]*)\)?", text, re.M)
    if not m:
        return []
    raw = m.group(1)
    return re.findall(r"[A-Za-z0-9_.$\-{}]+", raw)


def _lic(text):
    m = re.search(r"^license=\(?([^)\n]*)\)?", text, re.M)
    if not m:
        return ""
    parts = re.findall(r"'([^']+)'|\"([^\"]+)\"|([A-Za-z0-9_.+-]+)", m.group(1))
    return ", ".join(p[0] or p[1] or p[2] for p in parts if any(p))


def _build_hint(text):
    hints = []
    if "cargo build" in text or "cargo" in text:
        hints.append("cargo — needs pycargoebuild CRATES list")
    if "meson" in text:
        hints.append("meson")
    if "cmake" in text:
        hints.append("cmake")
    if re.search(r"\bmake\b", text):
        hints.append("make")
    if re.search(r"\bgo build\b", text):
        hints.append("go")
    if "python" in text and "setup.py" in text:
        hints.append("python")
    return "; ".join(hints) if hints else "—"


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "/tmp/alarm-aurora")
    sources = json.loads((root / "sources.json").read_text())
    pin_by_pkg = {}
    for key, v in sources.items():
        pin_by_pkg[key] = v
    rows = []
    for pkgdir in sorted((root / "packages").iterdir()):
        pb = pkgdir / "PKGBUILD"
        if not pb.is_file():
            continue
        text = pb.read_text(errors="replace")
        names = _names(text) or [pkgdir.name]
        ver = _first(r"^pkgver=(.+)$", text)
        # Expand simple ${_var} / $var references from assignments above it.
        if "${" in ver or ver.startswith("$"):
            for vm in re.finditer(r"^_(\w+)=(.+)$", text, re.M):
                ver = ver.replace("${_" + vm.group(1) + "}", vm.group(2).strip().strip("'\""))
                ver = ver.replace("$ _" + vm.group(1), vm.group(2).strip())
            ver = re.sub(r"\$\{?_?\w+\}?", "", ver) if "${" in ver else ver
        desc = _first(r"^pkgdesc=(.+)$", text)
        lic = _lic(text)
        pin = sources.get(pkgdir.name) or sources.get(names[0], {})
        pin_str = ""
        if pin:
            pin_str = f"{pin.get('version', '')} @ `{pin.get('commit', '')[:7]}`"
        rows.append(
            (pkgdir.name, ", ".join(names), ver, desc, lic, pin_str, _build_hint(text))
        )
    print(f"# alarm-aurora → Gentoo overlay: migration table\n")
    print(
        f"Generated from `{root}` — {len(rows)} PKGBUILDs, "
        f"{len(sources)} entries in `sources.json`. "
        "PKGBUILDs are parsed, never executed. "
        "Pin = `sources.json` version @ short commit; blank means no shared pin "
        "(version comes from the PKGBUILD itself or an Arch repo package).\n"
    )
    print("| alarm-aurora package | PKGBUILD pkgname(s) | pkgver | description | license | shared pin | build hint |")
    print("|---|---|---|---|---|---|---|")
    for r in rows:
        print("| " + " | ".join(r) + " |")
    print()
    print("Tiers (from the 2026-11-19 review; see README.md):")
    print("- **Tier 1 — must migrate, Aurora-only:** linux-aurora (+aurora-userpages), aura, uboot-aurora, speakerguardd(+v2), speakersafetyd-aurora-profiles, aurora-audio / alsa-ucm-conf-aurora, aurora-firmware / aurora-wifi-firmware, avd-fw + libva-v4l2-request-avd, SEP/Touch ID set, aurora-firstboot / aurora-boot / aurora-diag / aurora-kbd-light / aurora-camera-denoise / aurora-bless, mesa-aurora (+fex-guest) / aurora-flatpak-gl.")
    print("- **Tier 2 — patch overlay on ::gentoo instead of forking:** mutter/kwin/gnome-settings-daemon/iio-sensor-proxy, networkmanager, pipewire, plymouth (+theme), upower-aurora, fex-emu, omarchy-ane-tools / mil-hwx-compiler (experimental, last).")
    print("- **Tier 3 — do not migrate as-is:** aurora-keyring (pacman-only; Gentoo uses git signatures), aurora-system-fixes / aurora-keep-config (systemd presets/hwdb — rewrite as aurora-configs), small-patch Arch packages (docker/gtk2/udisks2/iwd/alsa-utils/plasma-setup).")


if __name__ == "__main__":
    main()

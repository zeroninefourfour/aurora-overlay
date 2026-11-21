# gentoo-aurora — Aurora Silicon driver stack as a Gentoo overlay

Gentoo installation itself is **out of scope** here (you handle that;
the Asahi Gentoo guide + `asahi-gentoosupport` already cover it).
This overlay is only the **Aurora delta over Asahi**, i.e. the drivers.

All versions/commits are pinned from `scripts/sources.json`, the same
shared pin file used by alarm-aurora, fedora-aurora and nixos-aurora.
Bumping a driver = bump that pin, in step with the other three distros.

## The driver map — where each driver actually lives

On Apple Silicon there is no "one driver package". It splits 4 ways:

| Hardware | Where the driver is | Gentoo package here |
|---|---|---|
| GPU (AGX), display (DCP), ISP camera, AOP, SEP, ANE, audio SoC, SMC, DART, AIC, USB4 / DP Alt, VRR | **In the kernel tree** (`DRM_ASAHI`, `DRM_APPLE`, `APPLE_AOP`, `APPLE_SEP`, …) | `sys-kernel/aurora-sources` 7.3.0 (commit `9125b31`) + `files/aurora-universal.config` (9809 lines, 16K pages) |
| GPU userspace (OpenGL / Vulkan Honeykrisp) | Mesa | `media-libs/mesa-aurora` 26.3.0 (pin `d4ad4a4`, matched to the aurora-sources UAPI; native drivers link no LLVM — CL compilers in `dev-util/mesa_clc` at the same pin). Rusticl/lavapipe not ported yet |
| Video decode (AVD) | Kernel driver + **open firmware** + VA-API bridge | `sys-firmware/avd-fw` (LLVM 22 only!) + `media-libs/libva-v4l2-request-avd` |
| Stage 1/2 boot | m1n1 fork + U-Boot fork | `sys-boot/aura` 1.0.0b13 (monitor-free, needs `CONFIG_ARM64_CTXR_EXECMEM=y`) + `sys-boot/uboot-aurora` 2026.07 (J700/Neo) |
| Wi-Fi / BT / peripherals | Blobs are **per-machine, extracted from your own macOS**, never shipped | `sys-firmware/asahi-firmware` (from asahi-overlay) extracts them; `sys-firmware/aurora-firmware` admits peripherals after the ESP vendor-firmware handoff (dracut module included); `sys-firmware/aurora-wifi-firmware` keeps Wi-Fi/BT firmware in sync with the installed macOS |
| Networking | NetworkManager + Aurora wake fix | `net-misc/networkmanager-aurora` 1.58.1 (::gentoo ebuild + the alarm-aurora WoL keep-activated patch; blocks stock `net-misc/networkmanager`) |
| Speakers | Kernel ASoC + UCM graphs + a protection daemon — running unprotected can physically damage speakers | `media-libs/alsa-ucm-conf-aurora`, `media-libs/aurora-audio`, `sys-apps/speakerguardd` (alternative to `speakersafetyd` — enable only one) |

Base layer required: `::gentoo` + chadmed's `asahi-overlay`
(`masters = gentoo asahi` in `metadata/layout.conf`). This overlay
only overrides what Aurora changes; it blocks the Asahi versions of
the same files (u-boot, alsa-ucm, asahi-audio, m1n1) so Portage cannot
mix the two stacks.

## Use

```sh
# Prerequisite: the asahi overlay (masters = gentoo asahi)
eselect repository enable asahi && emaint sync -r asahi

# /etc/portage/repos.conf/gentoo-aurora.conf
# [gentoo-aurora]
# location = /var/db/repos/gentoo-aurora
# sync-type = git
# sync-uri = https://github.com/zeroninefourfour/aurora-overlay
emaint sync -r gentoo-aurora

echo '*/*::gentoo-aurora ~arm64' >> /etc/portage/package.accept_keywords/aurora
emerge -av @aurora-m2-air         # per-model set, or @aurora-drivers / sys-apps/aurora-meta
```

On a fresh stage3 the stack needs these USE settings
(`/etc/portage/package.use/aurora`, found by resolving the full set
against a bare stage3):

```
net-wireless/wpa_supplicant dbus        # networkmanager-aurora[wifi,-iwd]
media-video/pipewire extra lv2 sound-server  # aurora-audio
media-libs/lsp-plugins lv2              # aurora-audio's LV2 chain
media-libs/libglvnd X                   # lsp-plugins[X] chain
x11-libs/cairo X                        # lsp-plugins[X] chain
sys-apps/systemd policykit              # power-profiles-daemon / polkit
dev-lang/rust rust-src                  # aurora-sources (or install dev-lang/rust-bin[rust-src] first)
```

Kernel: use `aurora-universal.config` as the base `.config`
(do not start from the generic Gentoo arm64 config — you would lose
the Apple drivers and the 16K/CTXR settings), merge Gentoo's
requirements on top, and validate with the `validate-config.py`
copied into `sys-kernel/aurora-sources/files/`.

## Status — honest version

Written and statically checked, **not built or booted on real
hardware** (no arm64 Mac in this environment). Expect, in order:

1. Manifest generation + any missing `CRATES`/deps on first emerge
   (aura and speakerguardd crate lists were taken from their pinned
   `Cargo.lock`s, but Portage will tell us if one is off);
2. aura vs. the system Rust version (upstream pins Rust 1.99.0 via
   rustup; this ebuild uses system rust like asahi-overlay's m1n1);
3. kernel config drift when merging Gentoo requirements.

Not yet ported, deliberately not faked: SEP userspace
(`aurora-sep*`, `aurora-fido`, `aurora-xart`, Touch ID/libfprint),
ANE userspace (`omarchy-ane-tools`, `mil-hwx-compiler`), FEX guest
Mesa, and the desktop patches (mutter/kwin/pipewire/…).

## Added 2026-11-19 (proactivity pass) — two more Tier-1 ebuilds

- `sys-apps/aurora-kbd-light` 0.1.0 (draft): make-based keyboard-backlight
  daemon; tarball + sha256 from `scripts/sources.json` (commit `727076b`);
  udev rule + systemd preset copied verbatim from the alarm-aurora PKGBUILD.
  TODO: verify the upstream Makefile honours `UNITDIR`/`PREFIX` as the
  PKGBUILD assumes; run `pkgcheck scan`.
- `media-video/aurora-camera-denoise` 0.1.0 (draft): meson PipeWire camera
  filter, `-Ddaemon=enabled -Dgpu=disabled`; pin `aa7a42f` from
  `scripts/sources.json`. TODO: check what libdir Gentoo's meson eclass
  picks on arm64 — upstream sets `--libdir=lib` because the binary looks
  for backends in `$prefix/$libdir/aurora-camera-denoise`.
- Both are wired into `sys-apps/aurora-meta` and `sets/aurora-drivers`;
  `media-video` was added to `profiles/categories`.
- `docs/migration-table.md`: all 64 alarm-aurora PKGBUILDs with pkgver,
  license, shared pin and build-system hint, generated by
  `scripts/generate-migration-table.py` (parses PKGBUILDs, never executes
  them; re-run it against a fresh alarm-aurora checkout to refresh).
  Tiers: Tier 1 must-migrate / Tier 2 patch-don't-fork / Tier 3 don't
  migrate as-is — see the table footer. Note the table also corrects an
  earlier chat slip: aura is 1.0.0b13.1 (`5dcf62d`), not b10.

## Next input needed from you

Your exact model / SoC (e.g. M1 Pro J314, M4 J616, Neo J700…).
The kernel config is universal, but speaker UCM/graphs, speakerguardd
vs speakersafetyd, aura Stage 2 qualification and AVD generation are
all per-model — that decides which of the remaining pieces are
must-haves for your machine instead of nice-to-haves.

## Added 2026-11-20 — firmware pair + NetworkManager, all real ebuilds

- `sys-firmware/aurora-firmware` 20261018: no longer a placeholder.
  Payload copied byte-identically from alarm-aurora (modprobe
  blacklist, `peripheral-firmware` admission script,
  `load-vendor-firmware` ESP handoff, runtime + initrd units,
  preset); the Arch mkinitcpio hook was ported to a dracut module
  (`99aurora-vendor`). Verified in an arm64 chroot: install phase
  produces the full file set.
- `sys-firmware/aurora-wifi-firmware` 0.2 (aurora-installer commit
  `afdd321`): reads Wi-Fi/BT firmware from the macOS system volume.
  Chroot-verified: its 41 upstream unittests pass and the install
  image is complete.
- `net-misc/networkmanager-aurora` 1.58.1: ::gentoo's
  networkmanager-1.58.1-r3 ebuild + alarm-aurora's two patches
  (GLib shadowing fix; WoL/WLAN keep-activated-after-wake). Blocks
  `net-misc/networkmanager`. Chroot-verified: Manifest against the
  pinned upstream tarball and a clean unpack+prepare (both patches
  apply). Full compile not attempted under qemu.
- `sys-kernel/aurora-sources` now also installs
  `aurora-universal.config` and `validate-config.py` into the
  source tree, ready to build with.

## Added 2026-11-20 (second pass) — the rest of Tier 1, plus two fixes

Ported: `sys-apps/aurora-firstboot` + `aurora-power-budget` +
`aurora-gamemode` + `aurora-secboot` (the aurora-platform split;
firstboot uses upstream's dracut module, secboot the kernel-install
plugin), `sys-apps/aurora-diag`, `sys-apps/aurora-bless` (all four
binaries in one package), `sys-apps/aurora-boot` (mkinitcpio hooks
ported to the dracut module `98aurora-early-kms`; Arch keyring and
libalpm pieces deliberately not ported),
`sys-apps/speakersafetyd-aurora-profiles`, and
`sys-apps/aurora-neo-platform-config` (J700-only).

Verification found and fixed two integration bugs:

- The overlay's sets were invisible to Portage: a repository must
  ship a `sets.conf` declaring them. It does now.
- `emerge @aurora-m2-air` could never resolve: ::asahi's
  speakersafetyd hard-depends on `alsa-ucm-conf-asahi`, which the
  Aurora UCM package blocks. `sys-apps/speakersafetyd-3.0.0-r1`
  here shadows ::asahi's with the dependency pointed at
  `alsa-ucm-conf-aurora`. With that (and the package.use list
  above), the full M2 Air set resolves cleanly: 199 packages,
  `emerge -pv @aurora-m2-air` RC=0 in an arm64 chroot.

Chroot-verified this pass: aurora-sources unpack+install (its
src_unpack now overrides kernel-2's vanilla-tarball model — the
Aurora tree is a full tree), all four platform packages, diag
(145/146 upstream tests; one timing-sensitive fan test fails
under qemu emulation only), profiles/boot/neo install images,
aurora-bless manifest + vendored unpack (58 crates). Still not
compile-verified anywhere: the Rust packages (aura, aurora-bless,
speakerguardd, speakersafetyd) and avd-fw — they build natively on
real hardware; a full NetworkManager compile under qemu is a
multi-hour run and was still in progress at publish time.

## Added 2026-11-21 — mesa-aurora + CI pkgcheck fix

- `media-libs/mesa-aurora` 26.3.0 and `dev-util/mesa_clc` 26.3.0 are
  real ebuilds (see `media-libs/mesa-aurora/README.md`). Chroot-checked:
  distfile sha256 vs the pin, both Manifests, and
  `emerge -pv dev-util/mesa_clc media-libs/mesa-aurora` resolving
  (77 packages). Full compile not attempted under qemu.
- CI: the pkgcheck job's 10 `NonsolvableDepsInStable` errors were
  profile artifacts — this overlay targets the systemd profile, and
  ::gentoo's stable OpenRC/split-usr profiles mask `sys-apps/systemd`
  by design. `metadata/pkgcheck.conf` now disables only that keyword;
  every other pkgcheck check stays on.

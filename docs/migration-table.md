# alarm-aurora → Gentoo overlay: migration table

Generated from `/tmp/alarm-aurora` — 64 PKGBUILDs, 33 entries in `sources.json`. PKGBUILDs are parsed, never executed. Pin = `sources.json` version @ short commit; blank means no shared pin (version comes from the PKGBUILD itself or an Arch repo package).

| alarm-aurora package | PKGBUILD pkgname(s) | pkgver | description | license | shared pin | build hint |
|---|---|---|---|---|---|---|
| alsa-ucm-conf-aurora | alsa-ucm-conf-aurora | 10.aurora2 | Aurora Apple Silicon ALSA profiles including J700 | BSD-3-Clause | 10 @ `96b3206` | — |
| alsa-utils-aurora | alsa-utils-aurora | 1.2.16 | ALSA utilities that leave controls locked by another process alone | GPL-2.0-or-later |  | make |
| asahi-scripts | asahi-scripts | 20261023 | Asahi Linux maintenance scripts | MIT |  | make |
| aura | aura | 1.0.0b13.1 | Aurora Silicon bootloader for Apple Silicon | MIT, GPL-2.0-only | 1.0.0b13.1 @ `5dcf62d` | make |
| aurora-audio | aurora-audio | 4.1.aurora2 | Aurora Apple Silicon PipeWire/WirePlumber DSP profiles including J700 | MIT | 4.1 @ `c967141` | make |
| aurora-bless | aurora-bless, aurora-nvram, aurora-btsync, aurora-panel-nits | 0.4.4.aurora5 | Aurora Apple Silicon startup-volume selector with Neo NVRAM support | MIT | 0.4.4 @ `9b47a17` | cargo — needs pycargoebuild CRATES list; make |
| aurora-boot | aurora-boot | 20261018 | Aurora Alarm boot integration | MIT |  | — |
| aurora-camera-denoise | aurora-camera-denoise | 0.1.0 | PipeWire filter that denoises the built-in camera on Apple silicon laptops, like macOS | MIT | 0.1.0 @ `aa7a42f` | meson |
| aurora-diag | aurora-diag | 0.5.0 | Bring-up diagnostics and regression checks for Apple silicon Macs (development only) | MIT | 0.5.0 @ `168fcb3` | make |
| aurora-fido | aurora-fido | 0.2.0 | Touch ID as a FIDO2/U2F security key for WebAuthn, SSH, pam_u2f (opt in: sudo aurora-fido enable) | MIT | 0.2.0 @ `2ea454e` | make |
| aurora-firmware | aurora-firmware | 20261018 | Aurora target-device firmware and peripheral admission | MIT |  | — |
| aurora-firstboot | aurora-firstboot, aurora-power-budget, aurora-gamemode, aurora-secboot | 0.1.13 | Aurora per-install root encryption and Linux owner setup | MIT | 0.1.13 @ `ddf5285` | make |
| aurora-flatpak-gl | aurora-flatpak-gl | 26.3.0_devel.202611150611.d4ad4a4dce6 | Aurora Mesa Flatpak GL extension for Freedesktop 25.08 and 26.08 | MIT |  | — |
| aurora-kbd-light | aurora-kbd-light | 0.1.0 | Keyboard backlight that follows the ambient light sensor on Apple silicon MacBooks, like macOS | MIT | 0.1.0 @ `727076b` | make |
| aurora-keep-config | aurora-keep-config | 1 | Keep configuration edited before a swap between a distribution package and its Aurora build | MIT |  | — |
| aurora-keyring | aurora-keyring | 20261018 | Public signing trust for Aurora Alarm packages | MIT |  | — |
| aurora-logos | aurora-logos | 1 | Aurora desktop icons and Plasma distribution artwork | MIT |  | — |
| aurora-neo-platform-config | aurora-neo-platform-config | 0.1.0 | Driver-scoped Aurora Neo NetworkManager and trackpad configuration | MIT | 0.1.0 @ `8f18039` | make |
| aurora-sep | aurora-sep | 1 | SEP trusted-key and fingerprint integration for Aurora | GPL-2.0-only |  | — |
| aurora-sep-luks | aurora-sep-luks | 0.3.0 | Unlock LUKS2 volumes with the Apple Secure Enclave (aurora-sep-cryptenroll, aurora-sep-fde, cryptsetup token, PAM) | MIT | 0.3.0 @ `96f5aa4` | make |
| aurora-sep-sk | aurora-sep-sk | 0.1.0 | OpenSSH security-key provider: ecdsa-sk keys in the Secure Enclave (members of the sep-key group) | MIT | 0.1.0 @ `72eaf54` | make |
| aurora-speaker-upgrade | aurora-speaker-upgrade | 0.1 | Move the speakers to speakerguardd v2 with this Mac'"'"'s own tuning (ships disabled; the legacy protection stays installed, --revert goes back) | MIT | 0.1 @ `bbd9ed3` | make |
| aurora-steam-native | aurora-steam-native, steam | 0.r202610301134.c06f610e360 | Valve's native ARM64 Steam client in a 4 KiB page process tree | MIT |  @ `c06f610` | — |
| aurora-system-fixes | aurora-system-fixes | 1 | Aurora systemd drop-ins awaiting named upstream fixes | MIT |  | — |
| aurora-touchid-rearm | aurora-touchid-rearm | 1 | Re-arm Touch ID with the password after a lockout | GPL-2.0-only | 1 @ `0996f01` | make |
| aurora-wifi-firmware | aurora-wifi-firmware | 0.2 | Keep the Wi-Fi and Bluetooth firmware on the installed macOS'"'"'s, as macOS does (read from the macOS system volume, applied at the next boot) | MIT | 0.2 @ `afdd321` | make |
| aurora-xart | aurora-xart | 0.1.0 | Inspect and manage the Linux side of the Secure Enclave and xART state on Apple silicon Macs | MIT | 0.1.0 @ `83ae189` | make |
| avd-fw | avd-fw | 0.1.aurora3 | Open replacement firmware for the Apple Video Decoder (AVD) on Apple Silicon | MIT | 0.1 @ `6062e85` | meson |
| bankstown | bankstown | 1.1.0 | LV2 bass enhancement used by Aurora Apple Silicon audio profiles | MIT | 1.1.0 @ `8e6f96f` | cargo — needs pycargoebuild CRATES list; make |
| docker | docker | 29.9.2 | Pack, ship and run any application as a lightweight container | Apache-2.0 |  | cmake; make |
| fex-emu | fex-emu, fex-emu-steam | 2610.r202611061239.0c08727ae4c | Fast usermode x86 and x86-64 emulator for ARM64 (Aurora build) | MIT, Apache-2.0, BSL-1.0, BSD-3-Clause, GPL-2.0-only | 2610 @ `0c08727` | cmake |
| firefox | firefox | 160.0 | Fast, Private & Safe Web Browser | MPL-2.0 |  | cargo — needs pycargoebuild CRATES list; make |
| fprintd-aurora | fprintd-aurora | 1.94.5 | D-Bus fingerprint service with Aurora enrolment and durable-delete handling | GPL-2.0-or-later, GFDL-1.1-or-later |  | meson |
| gnome-settings-daemon-aurora | gnome-settings-daemon-aurora | 51.1.aurora1 | GNOME Settings Daemon |  |  | meson |
| gtk2 | gtk2 | 2.24.33 | GObject-based multi-platform GUI toolkit (legacy) | LGPL-2.1-or-later |  | make |
| iio-sensor-proxy-aurora | iio-sensor-proxy-aurora | 3.9.aurora1 | IIO accelerometer sensor to input device proxy, reporting ambient colour temperature | GPL-3.0-only |  | meson |
| iwd-aurora | iwd-aurora | 3.12 | Internet Wireless Daemon, with OWE on FullMAC devices that offload it (Neo MT7932) | LGPL-2.1-or-later |  | make |
| kinfocenter | kinfocenter | 6.8.2 | A utility that provides information about a computer system | LGPL-2.0-or-later |  | cmake |
| kwin-aurora | kwin-aurora | 6.8.2.aurora1 | An easy to use, but flexible, Wayland compositor, with an opt-in ambient white point | LGPL-2.0-or-later |  | cmake |
| libfprint-aurora | libfprint-aurora | 1.94.100 | Fingerprint reader library with the Aurora SEP driver | LGPL-2.1-or-later, LicenseRef-NIST-PD | 1.94.100 @ `80a4b5e` | meson |
| libva-v4l2-request-avd | libva-v4l2-request-avd | 1.3.r11 | VA-API driver for the AVD V4L2 Request decoder | GPL-3.0-or-later | 1.3.r11 @ `4f60c51` | meson |
| linux-aurora | $pkgbase, $pkgbase-headers, aurora-userpages | 7.3.0.aurora1 |  | GPL2 |  | make |
| lsp-plugins-lv2 | lsp-plugins-lv2 | 1.2.37 | Collection of open-source plugins - LV2 (loud_comp latency fix) | LGPL-3.0-or-later |  | make |
| lzfse | lzfse | 1.0 | LZFSE compression library and command line tool | BSD-3-Clause |  | cmake; make |
| mesa-aurora | mesa-aurora, vulkan-aurora, opencl-rusticl-aurora, vulkan-lavapipe-aurora | 26.3.0_devel.202611150611.d4ad4a4dce6 | Aurora Asahi Gallium, Zink and Honeykrisp | MIT | 26.3.0 @ `d4ad4a4` | meson |
| mesa-aurora-fex-guest | mesa-aurora-fex-guest | 26.3.0_devel.202611150611.d4ad4a4dce6 | Aurora Mesa x86_64 and i686 graphics layer for the FEX guest | MIT | 26.3.0 @ `d4ad4a4` | meson |
| mil-hwx-compiler | mil-hwx-compiler | 0.3.1 | Open MIL to ANE HWX and ANEC compiler | MIT, LGPL-2.1-or-later | 0.3.1 @ `927013f` | cmake; make |
| mutter-aurora | mutter-aurora | 51.1.aurora4 | Window manager and compositor for GNOME, defaulting VRR-capable displays to variable refresh rate | GPL-2.0-or-later |  | meson |
| networkmanager-aurora | networkmanager-aurora | 1.58.1 | Network connection manager, keeping Wake-on-LAN devices that stay activated across sleep | LGPL-2.1-or-later, GPL-2.0-or-later |  | meson |
| omarchy-ane-tools | omarchy-ane-tools | 0.5.7 | Apple Neural Engine userspace tools for the in-kernel ANE driver | GPL-2.0-only OR MIT | 0.5.7 @ `68e9271` | make |
| omdrop-awdl | omdrop-awdl | 0.10.5 | AirDrop over firmware-native AWDL on Apple Silicon Macs (opt in) | GPL-2.0-only, MIT | 0.10.5 @ `ffc201f` | — |
| pipewire | pipewire | 1.6.10 | Low-latency audio/video router and processor | MIT |  | meson |
| plasma-setup | plasma-setup | 6.8.1 | First-run setup wizard for KDE Plasma that creates the initial user account | BSD-2-Clause |  | cmake |
| plymouth | plymouth | 26.134.222 | Graphical boot splash screen | GPL-2.0-or-later |  | meson |
| plymouth-theme-aurora | plymouth-theme-aurora | 1 | Aurora boot splash: the bootloader logo, kept in place, with the distribution branding | MIT |  | — |
| power-profiles-daemon | power-profiles-daemon | 0.30 | Makes power profiles handling available over D-Bus | GPL-3.0-only |  | meson |
| speakerguardd | speakerguardd | 0.1.12 | Apple speaker feed-forward protection with J700 profile | MIT | 0.1.12 @ `0287029` | cargo — needs pycargoebuild CRATES list |
| speakerguardd-v2 | speakerguardd-v2 | 1.0.0alpha.1 | In-graph speaker protection for Apple Silicon Macs (speakerguardd 1.0) | MIT | 1.0.0-alpha.1 @ `bbd9ed3` | cargo — needs pycargoebuild CRATES list |
| speakersafetyd | speakersafetyd | 2.0.1 | Speaker protection daemon for embedded Linux systems (Aurora build) | MIT |  | cargo — needs pycargoebuild CRATES list |
| speakersafetyd-aurora-profiles | speakersafetyd-aurora-profiles | 1 | speakersafetyd profiles for Aurora-supported Macs and warm restarts | GPL-2.0-only |  | — |
| triforce-lv2 | triforce-lv2 | 0.3.2 | Microphone-array beamformer used by Apple Silicon audio profiles | GPL-2.0-or-later |  | cargo — needs pycargoebuild CRATES list; make |
| uboot-aurora | uboot-aurora | 2026.07.aurora11 | Aurora common Apple Silicon U-Boot with Neo MTP handoff | GPL-2.0-or-later | 2026.07 @ `250385f` | make |
| udisks2 | udisks2 | 2.11.2 | Daemon, tools and libraries to access and manipulate disks, storage devices and technologies |  |  | make |
| upower-aurora | upower-aurora | 1.91.5.aurora1 | UPower with Aurora macsmc battery time reporting | GPL-2.0-or-later | 1.91.5 @ `d8a24ff` | meson |

Tiers (from the 2026-11-19 review; see README.md):
- **Tier 1 — must migrate, Aurora-only:** linux-aurora (+aurora-userpages), aura, uboot-aurora, speakerguardd(+v2), speakersafetyd-aurora-profiles, aurora-audio / alsa-ucm-conf-aurora, aurora-firmware / aurora-wifi-firmware, avd-fw + libva-v4l2-request-avd, SEP/Touch ID set, aurora-firstboot / aurora-boot / aurora-diag / aurora-kbd-light / aurora-camera-denoise / aurora-bless, mesa-aurora (+fex-guest) / aurora-flatpak-gl.
  **Status 2026-11-20: all of the above are ported except** mesa-aurora (+fex-guest) / aurora-flatpak-gl, the SEP/Touch ID set, speakerguardd v2, and aurora-userpages. networkmanager was ported as a full replacement package (net-misc/networkmanager-aurora) rather than a patch overlay, matching how the other Aurora distros ship it.
  **Update 2026-11-21:** mesa-aurora is ported (media-libs/mesa-aurora 26.3.0 + dev-util/mesa_clc 26.3.0, native GL/Honeykrisp only). Still open from this row: opencl-rusticl-aurora, vulkan-lavapipe-aurora, mesa-aurora-fex-guest, aurora-flatpak-gl.
- **Tier 2 — patch overlay on ::gentoo instead of forking:** mutter/kwin/gnome-settings-daemon/iio-sensor-proxy, pipewire, plymouth (+theme), upower-aurora, fex-emu, omarchy-ane-tools / mil-hwx-compiler (experimental, last).
- **Tier 3 — do not migrate as-is:** aurora-keyring (pacman-only; Gentoo uses git signatures), aurora-system-fixes / aurora-keep-config (systemd presets/hwdb — rewrite as aurora-configs), small-patch Arch packages (docker/gtk2/udisks2/iwd/alsa-utils/plasma-setup).

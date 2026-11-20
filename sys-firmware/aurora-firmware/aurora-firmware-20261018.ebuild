# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora aurora-firmware 20261018. The package has no
# upstream tarball: its payload is the scripts/units in files/, copied
# byte-identically from alarm-aurora (sha256s match its PKGBUILD).
#
# What it does: drivers that request per-machine firmware during probe
# (aop, mt7932 radios, dockchannel-hid keyboard/trackpad) are
# blacklisted from modalias autoload. In the initrd, the vendor
# firmware is extracted from the ESP (vendorfw/firmware.cpio, as put
# there by the installer / asahi-firmware tooling), the firmware_class
# search path is pointed at it, and only then are the peripherals
# admitted with explicit modprobes. The runtime service repeats the
# handoff on the real root and admits Bluetooth there.
#
# The Arch package ships an mkinitcpio hook; here that hook is ported
# to a dracut module (files/dracut-module-setup.sh, installed as
# modules.d/99aurora-vendor), which is the Gentoo equivalent.

EAPI=8

inherit systemd

# No upstream tarball: the payload is entirely in FILESDIR.
S="${WORKDIR}"

DESCRIPTION="Aurora target-device firmware and peripheral admission"
HOMEPAGE="https://github.com/aurora-silicon/alarm-aurora"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"
IUSE="+initramfs"

RDEPEND="
	app-arch/cpio
	app-shells/bash
	net-wireless/wireless-regdb
	sys-apps/asahi-scripts
	sys-apps/kmod
	sys-apps/util-linux
	initramfs? ( sys-kernel/dracut )
"

src_install() {
	insinto /usr/lib/modprobe.d
	doins "${FILESDIR}/aurora-firmware-order.conf"

	exeinto /usr/libexec/aurora
	newexe "${FILESDIR}/aurora-peripheral-firmware.sh" peripheral-firmware
	doexe "${FILESDIR}/load-vendor-firmware"

	systemd_dounit "${FILESDIR}/aurora-peripherals.service"

	insinto /usr/lib/systemd/system-preset
	doins "${FILESDIR}/90-aurora-peripherals.preset"

	# Unit for the initrd copy of the system (staged by dracut).
	insinto /usr/lib/aurora/initrd
	doins "${FILESDIR}/aurora-vendor-firmware.service"

	if use initramfs; then
		exeinto /usr/lib/dracut/modules.d/99aurora-vendor
		newexe "${FILESDIR}/dracut-module-setup.sh" module-setup.sh
	fi
}

pkg_postinst() {
	elog "Peripheral admission is enabled via systemd preset:"
	elog "  systemctl preset aurora-peripherals.service"
	elog "The vendor firmware itself is per-machine and comes from"
	elog "the ESP (vendorfw/firmware.cpio), as extracted by the"
	elog "installer / sys-firmware/asahi-firmware tooling."
	if use initramfs; then
		elog "Rebuild the initramfs so the Aurora vendor-firmware"
		elog "dracut module is included, e.g.:  dracut --force"
	fi
}

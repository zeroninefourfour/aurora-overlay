# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora aurora-wifi-firmware 0.2 (shared sources.json pin,
# aurora-installer commit below). Keeps the Wi-Fi and Bluetooth firmware
# on the installed macOS, as macOS does: the service reads the firmware
# from the macOS system volume and stages it so it is applied at the
# next boot. The tool bundles its own asahi_firmware converters, so no
# other copy of them is needed.

EAPI=8

COMMIT="afdd3215189cb5badb85d22bdb255df4a7b3a9fa"

DESCRIPTION="Wi-Fi/Bluetooth firmware read from the installed macOS system volume (Aurora)"
HOMEPAGE="https://github.com/aurora-silicon/aurora-installer/tree/main/tools/wifi-firmware"
SRC_URI="https://codeload.github.com/aurora-silicon/aurora-installer/tar.gz/${COMMIT} -> aurora-installer-${COMMIT}.tar.gz"
S="${WORKDIR}/aurora-installer-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"
IUSE="lzfse"

# python: the tool is a python program run with the system interpreter.
RDEPEND="
	dev-lang/python
	sys-apps/systemd
	sys-apps/util-linux
	lzfse? ( app-arch/lzfse )
"
DEPEND="${RDEPEND}"

src_test() {
	/usr/bin/python3 -I -m unittest discover -s tests \
		-p 'test_wifi_firmware_*.py' || die "wifi-firmware tests failed"
}

src_install() {
	emake -C tools/wifi-firmware install DESTDIR="${D}" PREFIX=/usr \
		UNITDIR=/usr/lib/systemd/system PYTHON=/usr/bin/python3

	# On for every Mac: macOS runs the Wi-Fi firmware its system
	# volume ships. Applied with `systemctl preset` (see postinst).
	insinto /usr/lib/systemd/system-preset
	doins "${FILESDIR}/80-aurora-wifi-firmware.preset"

	dodoc tools/wifi-firmware/README.md
}

pkg_postinst() {
	elog "Enable the firmware refresh service once:"
	elog "  systemctl preset aurora-wifi-firmware.service"
	elog "It takes effect at the next boot: the firmware is read from"
	elog "the macOS system volume, like macOS itself does. LZFSE-"
	elog "compressed files on that volume need USE=lzfse."
}

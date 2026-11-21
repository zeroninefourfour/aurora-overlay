# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora aurora-diag 0.5.0 (shared sources.json pin).
# Bring-up diagnostics and regression checks; development tooling.

EAPI=8

inherit optfeature

COMMIT="168fcb3852ce2562cda9de90ca9315733e0ab5f6"

DESCRIPTION="Bring-up diagnostics and regression checks for Apple silicon Macs"
HOMEPAGE="https://github.com/aurora-silicon/aurora-diag"
SRC_URI="https://codeload.github.com/aurora-silicon/aurora-diag/tar.gz/${COMMIT} -> ${PN}-${COMMIT}.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

RDEPEND="dev-lang/python"
DEPEND="${RDEPEND}"

src_test() {
	emake check
}

src_compile() {
	# Nothing to build: the upstream Makefile's default target is
	# "install" itself, which portage's default src_compile would
	# run without DESTDIR. Installation happens in src_install.
	:;
}

src_install() {
	emake install DESTDIR="${D}" PREFIX=/usr
	dodoc README.md
}

pkg_postinst() {
	optfeature "the dashboard" dev-python/textual
	optfeature "ALSA control readout" media-sound/alsa-utils
	optfeature "Wi-Fi link and regulatory readout" net-wireless/iw
	optfeature "NVMe SMART health" sys-apps/smartmontools
	optfeature "Bluetooth controller readout" net-wireless/bluez
}

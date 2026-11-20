# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora aurora-neo-platform-config 0.1.0 (shared
# sources.json pin). Driver-scoped configuration for the MacBook
# Neo (J700) only: a NetworkManager drop-in for its MT7932 radio and
# a libinput quirks file for its trackpad. Not needed on other Macs.

EAPI=8

COMMIT="8f18039e37ccdec03049d04844d59de2909f680c"

DESCRIPTION="Driver-scoped Aurora Neo (J700) NetworkManager and trackpad configuration"
HOMEPAGE="https://github.com/aurora-silicon/aurora-neo-platform-config"
SRC_URI="https://codeload.github.com/aurora-silicon/aurora-neo-platform-config/tar.gz/${COMMIT} -> ${PN}-${COMMIT}.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

RDEPEND="
	net-misc/networkmanager-aurora
	x11-libs/libinput
"

src_test() {
	sh tests/run.sh || die "neo-platform-config tests failed"
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

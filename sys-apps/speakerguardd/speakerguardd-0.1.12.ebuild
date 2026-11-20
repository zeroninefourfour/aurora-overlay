# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Feed-forward speaker protection. IMPORTANT: on machines where this
# applies it REPLACES speakersafetyd's job -- do not run both.
# alarm-aurora ships a systemd drop-in that interlocks the two
# (speakersafetyd.service.d/50-j700-guard.conf); the same interlock is
# needed here if you also install sys-apps/speakersafetyd.

EAPI=8

CRATES="
	libc@0.2.189
"
inherit cargo systemd udev

COMMIT="0287029648842be7b62ce9869ceaf5dbe9555831"

DESCRIPTION="Feed-forward speaker protection daemon for Apple laptops (Aurora)"
HOMEPAGE="https://github.com/aurora-silicon/speakerguardd"
SRC_URI="https://codeload.github.com/aurora-silicon/speakerguardd/tar.gz/${COMMIT} -> speakerguardd-${COMMIT}.tar.gz
	${CARGO_CRATE_URIS}"
S="${WORKDIR}/speakerguardd-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

DEPEND="media-libs/alsa-lib"
RDEPEND="${DEPEND}"

src_compile() {
	export SPEAKERGUARDD_COMMIT="${COMMIT:0:12}"
	cargo_src_compile
}

src_install() {
	cargo_src_install
	insinto /usr/share/speakerguardd
	doins -r conf
	systemd_dounit speakerguardd.service
	udev_dorules 95-speakerguardd.rules
}

pkg_postinst() {
	elog "speakerguardd is an alternative to speakersafetyd, not an add-on."
	elog "Enable only one speaker-protection daemon for your machine."
}

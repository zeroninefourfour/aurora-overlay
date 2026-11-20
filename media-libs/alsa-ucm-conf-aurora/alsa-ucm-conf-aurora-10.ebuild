# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Aurora pin of alsa-ucm-conf-asahi: adds J616s (M4 Pro 16") speaker/jack
# cards and the J700 microphone-jack change over the Asahi pin used by
# asahi-overlay's media-libs/alsa-ucm-conf-asahi. Same files, newer pin:
# this package blocks the Asahi one.

EAPI=8

COMMIT="96b3206d2f4c6f89145a2f1b5395a833fb2ae0af"

DESCRIPTION="ALSA UCM configuration for Apple Silicon devices (Aurora pin)"
HOMEPAGE="https://github.com/aurora-silicon/alsa-ucm-conf-asahi"
SRC_URI="https://codeload.github.com/aurora-silicon/alsa-ucm-conf-asahi/tar.gz/${COMMIT} -> alsa-ucm-conf-aurora-${COMMIT}.tar.gz"
S="${WORKDIR}/alsa-ucm-conf-asahi-${COMMIT}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~arm64"

RDEPEND="
	>=media-libs/alsa-lib-1.2.1
	!media-libs/alsa-ucm-conf-asahi
"
DEPEND="${RDEPEND}
	media-libs/alsa-ucm-conf"

src_install() {
	insinto /usr/share/alsa
	doins -r ucm2
}

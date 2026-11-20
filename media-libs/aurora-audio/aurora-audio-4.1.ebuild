# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Aurora pin of asahi-audio: J616s speaker graph + headphone-jack
# priorities and the J700 graph (+3 dB make-up gain, brick-wall limiter)
# over asahi-overlay's asahi-audio. Same layout, blocks it.
# NOTE: alarm-aurora also carries a patch restoring legacy speaker
# graphs (0001-restore-legacy-speaker-graphs.patch) -- check whether
# your machine needs it before dropping it; see README.md.

EAPI=8

COMMIT="c967141161bea3badc7754e23d80b39ffb1bdafd"

DESCRIPTION="PipeWire/WirePlumber audio configuration for Apple Silicon (Aurora pin)"
HOMEPAGE="https://github.com/aurora-silicon/asahi-audio"
SRC_URI="https://codeload.github.com/aurora-silicon/asahi-audio/tar.gz/${COMMIT} -> aurora-audio-${COMMIT}.tar.gz"
S="${WORKDIR}/asahi-audio-${COMMIT}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="-* ~arm64"

RDEPEND="
	>=media-video/pipewire-1.0.2[extra,lv2,sound-server]
	>=media-video/wireplumber-0.5.2
	media-libs/alsa-ucm-conf-aurora
	>=media-libs/lsp-plugins-1.2.6[lv2]
	>=media-libs/bankstown-lv2-1.1.0
	media-libs/triforce-lv2
	!media-libs/asahi-audio
"
DEPEND="${RDEPEND}"

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr install
}

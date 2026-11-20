# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

S="${WORKDIR}"

DESCRIPTION="Aurora Silicon driver stack for Gentoo (metapackage)"
HOMEPAGE="https://github.com/aurora-silicon"
LICENSE="metapackage"
SLOT="0"
KEYWORDS="-* ~arm64"
IUSE="video-decoding"

# Speaker protection is per-model: speakersafetyd covers most
# machines (incl. M2 Air J413/J415). speakerguardd is the J700
# (MacBook Neo) feed-forward alternative — swap it in by hand
# on that machine only, never run both.
RDEPEND="
	sys-kernel/aurora-sources
	sys-boot/aura
	sys-boot/uboot-aurora
	sys-apps/aurora-bless
	sys-apps/aurora-firstboot
	sys-apps/aurora-power-budget
	sys-apps/aurora-secboot
	sys-apps/aurora-boot
	sys-firmware/aurora-firmware
	sys-firmware/aurora-wifi-firmware
	media-libs/alsa-ucm-conf-aurora
	media-libs/aurora-audio
	sys-apps/speakersafetyd
	sys-apps/aurora-kbd-light
	media-video/aurora-camera-denoise
	video-decoding? (
		sys-firmware/avd-fw
		media-libs/libva-v4l2-request-avd
	)
"

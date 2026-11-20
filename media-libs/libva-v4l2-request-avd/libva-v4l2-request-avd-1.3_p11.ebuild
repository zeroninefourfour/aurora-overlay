# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# VA-API front end for the kernel AVD driver. Without this, the AVD
# kernel driver + avd-fw exist but Firefox/ffmpeg cannot use HW decode.

EAPI=8
inherit meson

COMMIT="4f60c51f7841dd74bb61c94a4ad31e630bbdab01"
MY_PN="libva-v4l2_request"

DESCRIPTION="VA-API driver for V4L2 stateless decoders, with Apple AVD fixes"
HOMEPAGE="https://github.com/aurora-silicon/libva-v4l2_request"
SRC_URI="https://codeload.github.com/omacom/${MY_PN}/tar.gz/${COMMIT} -> ${MY_PN}-${COMMIT}.tar.gz"
S="${WORKDIR}/${MY_PN}-${COMMIT}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="-* ~arm64"
# Default to the codecs the Apple AVD actually exposes (H.264/HEVC);
# without any codec the package is useless, hence REQUIRED_USE below.
IUSE="+h264 +hevc vp9 av1"
REQUIRED_USE="|| ( h264 hevc vp9 av1 )"

DEPEND="
	x11-libs/libdrm
	media-libs/libva
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/0001-offline-test-portability.patch" )

src_configure() {
	local emesonargs=(
		-Ddriverdir=/usr/$(get_libdir)/dri
		-Dcodec_h264=$(usex h264 enabled disabled)
		-Dcodec_hevc=$(usex hevc enabled disabled)
		-Dcodec_vp9=$(usex vp9 enabled disabled)
		-Dcodec_av1=$(usex av1 enabled disabled)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	# mpv/ffmpeg look up the driver by the DRM driver name.
	dosym v4l2_request_drv_video.so /usr/$(get_libdir)/dri/asahi_drv_video.so
	# Aurora kernels name the AGX render node driver "aurora".
	dosym v4l2_request_drv_video.so /usr/$(get_libdir)/dri/aurora_drv_video.so
}

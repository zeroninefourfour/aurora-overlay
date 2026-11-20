# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# DRAFT — not yet tested on Gentoo or on Apple Silicon hardware.
# Translated from alarm-aurora's aurora-camera-denoise PKGBUILD (pkgver
# 0.1.0, pkgrel 9): same upstream tarball, same commit, same sha256,
# same meson options (-Ddaemon=enabled -Dgpu=disabled).
# TODO before first emerge: upstream sets --libdir=lib because the binary
# looks for backends in $prefix/$libdir/aurora-camera-denoise; check what
# libdir Gentoo's meson eclass picks on arm64 and whether the backend
# directory lands in the right place. Run `pkgcheck scan`.

EAPI=8

inherit meson systemd

_COMMIT="aa7a42ff3f26ac47c07b4cdb4ab1bfc5337291af"
DESCRIPTION="PipeWire filter that denoises the built-in camera on Apple silicon laptops, like macOS"
HOMEPAGE="https://github.com/aurora-silicon/camera-denoise"
SRC_URI="https://codeload.github.com/aurora-silicon/camera-denoise/tar.gz/${_COMMIT} -> ${P}-${_COMMIT:0:7}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"
IUSE=""

DEPEND="media-video/pipewire"
RDEPEND="${DEPEND}"

S="${WORKDIR}/camera-denoise-${_COMMIT}"

src_configure() {
	local emesonargs=(
		-Ddaemon=enabled
		-Dgpu=disabled
		-Dsystemduserunitdir=/usr/lib/systemd/user
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	# Backends (cdn-backend-ave.so / cdn-backend-ane.so) install here;
	# without them the filter falls back to the built-in CPU backend.
	keepdir /usr/lib/aurora-camera-denoise
	insinto /usr/lib/systemd/user-preset
	newins "${FILESDIR}/80-aurora-camera-denoise.preset" 80-aurora-camera-denoise.preset
}

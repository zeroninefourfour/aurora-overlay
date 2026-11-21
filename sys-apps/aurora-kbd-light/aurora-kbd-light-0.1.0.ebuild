# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# DRAFT — not yet tested on Gentoo or on Apple Silicon hardware.
# Translated from alarm-aurora's aurora-kbd-light PKGBUILD (pkgver 0.1.0,
# pkgrel 3): same upstream tarball, same commit, same sha256, same
# `make install DESTDIR=... PREFIX=/usr UNITDIR=...` install step.
# The udev rule and systemd preset are copied verbatim from that PKGBUILD.
# TODO before first emerge: verify the upstream Makefile honours
# UNITDIR/PREFIX exactly as the PKGBUILD assumes, and run `pkgcheck scan`.

EAPI=8

inherit udev

_COMMIT="727076b83eb65b0162317a9e2fa0ba850df1f5ca"
DESCRIPTION="Keyboard backlight daemon following the ambient light sensor"
HOMEPAGE="https://github.com/aurora-silicon/kbd-light"
SRC_URI="https://codeload.github.com/aurora-silicon/kbd-light/tar.gz/${_COMMIT} -> ${P}-${_COMMIT:0:7}.tar.gz"
S="${WORKDIR}/kbd-light-${_COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~arm64"

src_compile() {
	emake CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
}

src_install() {
	emake install DESTDIR="${D}" PREFIX=/usr UNITDIR=/usr/lib/systemd/system
	udev_dorules "${FILESDIR}/90-aurora-kbd-light.rules"
	insinto /usr/lib/systemd/system-preset
	newins "${FILESDIR}/80-aurora-kbd-light.preset" 80-aurora-kbd-light.preset
}

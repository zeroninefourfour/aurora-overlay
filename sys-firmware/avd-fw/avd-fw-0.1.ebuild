# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Aurora's avd-fw: open replacement firmware for the Apple Video Decoder.
# PIN NOTE: alarm-aurora requires LLVM 22 exactly -- LLVM 23 changes the
# image bytes and breaks the shared hash manifest in its check() phase.
# Keep LLVM_COMPAT=( 22 ) until Aurora re-pins.

EAPI=8
LLVM_COMPAT=( 22 )
inherit meson llvm-r2

COMMIT="6062e8516c0a751bc8e50f5d604a17395923189f"

DESCRIPTION="Open replacement firmware for the Apple Video Decoder (AVD)"
HOMEPAGE="https://github.com/aurora-silicon/avd-fw"
SRC_URI="https://codeload.github.com/aurora-silicon/avd-fw/tar.gz/${COMMIT} -> avd-fw-aurora-${COMMIT}.tar.gz"
S="${WORKDIR}/avd-fw-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

BDEPEND="
	llvm-core/clang:22
	llvm-core/llvm:22
	llvm-core/lld:22
"

src_configure() {
	local emesonargs=(
		--cross-file=./llvm.ini
		--libdir=lib
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	# Firmware blobs are not executables (alarm-aurora does the same fix).
	chmod 0644 "${ED}"/usr/lib/firmware/apple/*.bin || die
}

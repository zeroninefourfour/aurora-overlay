# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Adapted from asahi-overlay sys-boot/u-boot. Aurora's fork adds the
# J700 (MacBook Neo) MTP handoff; DTBs come from the kernel, not here.

EAPI=8
PYTHON_COMPAT=( python3_{11..14} )
inherit toolchain-funcs python-any-r1

COMMIT="250385f8c8aaafd47a8f7990f6efe0443c28d0b5"

DESCRIPTION="Aurora Silicon fork of Das U-Boot for Apple Silicon"
HOMEPAGE="https://github.com/aurora-silicon/u-boot"
SRC_URI="https://codeload.github.com/aurora-silicon/u-boot/tar.gz/${COMMIT} -> u-boot-aurora-${COMMIT}.tar.gz"
S="${WORKDIR}/u-boot-${COMMIT}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="-* ~arm64"

BDEPEND="
	sys-devel/bc
	sys-apps/dtc
	$(python_gen_any_dep 'dev-python/pyelftools[${PYTHON_USEDEP}]')
	dev-lang/swig
	dev-libs/openssl
"
RDEPEND="sys-apps/asahi-scripts"
# Blocks the Asahi U-Boot in asahi-overlay: both install
# /usr/lib/asahi-boot/u-boot-nodtb.bin
RDEPEND="${RDEPEND} !sys-boot/u-boot"

src_configure() {
	emake HOSTCC="$(tc-getCC)" CC="$(tc-getCC)" apple_m1_defconfig
}

src_compile() {
	# lld produces a wrong image-size header here (known asahi-overlay bug); force bfd.
	tc-ld-force-bfd
	emake HOSTCC="$(tc-getCC)" CC="$(tc-getCC)" HOSTLD="$(tc-getLD)" LD="$(tc-getLD)"
}

src_install() {
	insinto /usr/lib/asahi-boot
	doins u-boot-nodtb.bin
}

pkg_postinst() {
	elog "Run update-m1n1 to install this U-Boot into the ESP Stage 2 bundle."
	elog "Never write it to Stage 1 manually."
}

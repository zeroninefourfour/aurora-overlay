# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Aurora kernel sources: aurora-silicon/linux, pinned exactly as in
# alarm-aurora / fedora-aurora / nixos-aurora sources.json (shared pin).
# This is a *full* tree (not a patchset on top of kernel.org), because the
# Aurora tree carries drivers that have no Asahi-tag equivalent:
# DRM_ASAHI G15/G16/M3, DRM_APPLE (DCP) audio, APPLE_AOP, APPLE_SEP,
# AVD, USB4 / DP Alt Mode, VRR, and CONFIG_APPLE_AURORA_BOOT_SECURITY.
# In-kernel drivers live here -- there is no separate "driver package"
# for GPU/display/camera/ANE/SEP on Apple Silicon.

EAPI=8
ETYPE="sources"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"

RUST_MIN_VER="1.85.0"
RUST_REQ_USE='rust-src,rustfmt'

inherit kernel-2 rust
detect_version
detect_arch

COMMIT="9125b31475836ce0a6634df45b539c6d604f36a5"

DESCRIPTION="Aurora Silicon (Apple Silicon) kernel sources"
HOMEPAGE="https://github.com/aurora-silicon/linux"
SRC_URI="https://codeload.github.com/aurora-silicon/linux/tar.gz/${COMMIT} -> linux-aurora-${COMMIT}.tar.gz"
S="${WORKDIR}/linux-${COMMIT}"

LICENSE="GPL-2"
SLOT="${PV}"
KEYWORDS="-* ~arm64"

# 16K pages are mandatory: files/aurora-universal.config is the shared
# Aurora universal config (CONFIG_ARM64_16K_PAGES=y). Do not merge the
# Gentoo generic arm64 config over it blindly; use it as the base and
# layer Gentoo requirements on top (see README.md).
DEPEND="${DEPEND}
	dev-util/bindgen
"

src_unpack() {
	# kernel-2's universal_unpack hardcodes the vanilla-tarball
	# model (unpack linux-${KV_MAJOR}.${KV_MINOR}.tar.xz). The
	# Aurora tree is a full tree, not a patchset: unpack only the
	# pinned codeload tarball, which already extracts to ${S}.
	unpack ${A}
}

src_install() {
	kernel-2_src_install

	# Ship the Aurora universal config and its validator inside the
	# installed source tree, ready to build with.
	local kdirs=( "${ED}"/usr/src/linux-* )
	[[ -d ${kdirs[0]} ]] || die "installed kernel source dir not found"
	insinto "/usr/src/${kdirs[0]##*/}"
	doins "${FILESDIR}/aurora-universal.config" \
		"${FILESDIR}/validate-config.py"
}

pkg_postinst() {
	elog "The Aurora universal config and validate-config.py were"
	elog "installed into the source tree (/usr/src/linux-*/)."
	elog "Build with:"
	elog "  cd /usr/src/linux"
	elog "  cp aurora-universal.config .config"
	elog "  python3 validate-config.py .config"
	elog "  make olddefconfig && make -j\$(nproc) Image modules dtbs"
	elog "CONFIG_ARM64_CTXR_EXECMEM=y (in the config) is required by"
	elog "sys-boot/aura (no monitor); do not drop it."
	kernel-2_pkg_postinst
}

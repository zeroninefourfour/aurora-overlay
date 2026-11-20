# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Aura = Aurora's m1n1 fork. Differences that matter for Gentoo:
#  * No monitor (src/monitor.c is gone, src/ctxr_exec.c exists):
#    it moves the kernel into the CTXR window, so it REQUIRES the
#    kernel to be built with CONFIG_ARM64_CTXR_EXECMEM=y.
#    aurora-sources' universal config satisfies this; asahi-sources
#    is NOT guaranteed to. Do not pair aura with asahi-sources.
#  * Provides m1n1 compatibility 1.6.1.aurora19 in the other distros;
#    here it blocks sys-boot/m1n1{,-bin} and installs to the same
#    /usr/lib/asahi-boot/m1n1.bin path so update-m1n1 works unchanged.
#  * Stage 1 images (aura{,-boot}.macho, secure flavour) are built by
#    alarm/fedora too, but Gentoo users should only ever refresh
#    Stage 2 via update-m1n1 -- Stage 1 enrolment is out of scope here
#    and is NOT installed by this ebuild.
#  * Rust toolchain: upstream pins 1.99.0 via rustup. Gentoo uses the
#    system rust with the aarch64-unknown-none-softfloat target, the
#    same approach as asahi-overlay's m1n1 ebuild; if the system rust
#    is older than the pin, the build may fail -- see README.md.

EAPI=8

CRATES="
	bitflags@2.13.0
	block-buffer@0.10.4
	cfg-if@1.0.5
	cpufeatures@0.2.17
	crypto-common@0.1.7
	digest@0.10.7
	ed25519-compact@2.6.1
	generic-array@0.14.7
	libc@0.2.191
	log@0.4.33
	sha1_smol@1.0.1
	sha2@0.10.9
	typenum@1.20.1
	uuid@1.23.4
	version_check@0.9.5
"
declare -A GIT_CRATES=(
	[fatfs]='https://github.com/aurora-silicon/fatfs;7d505fbfa37a945af5549517f47c1d2e87a8333e;fatfs-%commit%'
)

RUST_MIN_VER="1.89.0"
RUST_REQ_USE="rust-src"
inherit cargo

COMMIT="5dcf62d0bf28e42c0e3f4ece44908643ffd40837"

DESCRIPTION="Aurora Silicon bootloader for Apple Silicon (m1n1 fork)"
HOMEPAGE="https://github.com/aurora-silicon/aura"
SRC_URI="https://codeload.github.com/aurora-silicon/aura/tar.gz/${COMMIT} -> aura-${COMMIT}.tar.gz
	${CARGO_CRATE_URIS}"
S="${WORKDIR}/aura-${COMMIT}"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="-* ~arm64"
IUSE="clang"

BDEPEND="
	dev-build/make
	dev-lang/rust[rust-src]
	clang? ( llvm-core/clang )
"
RDEPEND="
	sys-boot/uboot-aurora
	!sys-boot/m1n1
	!sys-boot/m1n1-bin
"

src_prepare() {
	if [[ ! -d "${BROOT}"/usr/lib/rustlib/aarch64-unknown-none-softfloat/ ]]; then
		eerror "aarch64-unknown-none-softfloat Rust target is not installed!"
		eerror "Rebuild dev-lang/rust with that target, as for sys-boot/m1n1."
		die "Rust target dependency not met: aarch64-unknown-none-softfloat"
	fi
	[[ -f src/ctxr_exec.c && ! -f src/monitor.c ]] || \
		die "Pinned aura is not the expected monitor-free/CTXR build; re-check the pin."
	default
}

src_compile() {
	export AURA_VERSION_TAG="$(cat VERSION)-g${COMMIT:0:8}"
	if use clang; then
		emake RELEASE=1 CHAINLOADING=1 USE_CLANG=1 BUILTIN_LOGO=aurora
	else
		emake RELEASE=1 CHAINLOADING=1 USE_CLANG=0 BUILTIN_LOGO=aurora ARCH="${CHOST}-"
	fi
}

src_install() {
	insinto /usr/lib/asahi-boot
	doins build/aura.bin
	dosym aura.bin /usr/lib/asahi-boot/m1n1.bin
	# Marker that this Stage 2 is monitor-free (other Aurora distros
	# ship /usr/share/aura/monitor-free; update tooling checks for it).
	insinto /usr/share/aura
	: > "${T}"/monitor-free
	doins "${T}"/monitor-free
}

pkg_postinst() {
	elog "Run update-m1n1 to trial this Aura in ESP Stage 2."
	elog "Pair ONLY with sys-kernel/aurora-sources (CTXR_EXECMEM)."
}

# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora aurora-bless 0.4.4.aurora5 (shared sources.json
# pin; the Arch package uses a git checkout, here the same commit as a
# tarball so the Manifest pins it). One Gentoo package installs the
# four workspace binaries the Arch split packages ship:
#   aurora-bless      (asahi-bless, + asahi-bless symlink) — replaces
#                     sys-apps/asahi-bless
#   aurora-nvram      (+ asahi-nvram symlink) — replaces asahi-nvram
#   aurora-btsync     (+ asahi-btsync symlink, service, udev rule)
#   aurora-panel-nits (panel brightness via NVRAM, + its units)
# The asahi-* command names keep working through the symlinks.
# asahi-wifisync is in the workspace but is not built (alarm does not
# ship it either; Wi-Fi sync is aurora-wifi-firmware's job).

EAPI=8

CRATES="
	adler32@1.2.0
	anstream@0.6.18
	anstyle@1.0.10
	anstyle-parse@0.2.6
	anstyle-query@1.1.2
	anstyle-wincon@3.0.6
	bitflags@2.6.0
	cfg-if@1.0.0
	cfg_aliases@0.2.1
	clap@4.5.21
	clap_builder@4.5.21
	clap_derive@4.5.18
	clap_lex@0.7.3
	colorchoice@1.0.3
	const-random@0.1.18
	const-random-macro@0.1.16
	crc@3.2.1
	crc-catalog@2.4.0
	crc32fast@1.4.2
	crunchy@0.2.3
	dbus@0.9.7
	dlv-list@0.5.2
	getrandom@0.2.15
	gpt@3.1.0
	hashbrown@0.14.5
	heck@0.5.0
	is_terminal_polyfill@1.70.1
	libc@0.2.164
	libdbus-sys@0.2.5
	log@0.4.22
	nix@0.29.0
	once_cell@1.20.2
	ordered-multimap@0.7.3
	pkg-config@0.3.31
	proc-macro2@1.0.92
	quote@1.0.37
	rust-ini@0.21.1
	strsim@0.11.1
	syn@2.0.89
	tiny-keccak@2.0.2
	trim-in-place@0.1.7
	unicode-ident@1.0.14
	utf8parse@0.2.2
	uuid@1.11.0
	wasi@0.11.0+wasi-snapshot-preview1
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	windows-sys@0.59.0
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6"

inherit cargo systemd

COMMIT="9b47a17827854588d458b1dcc8018c66f5c3237f"

DESCRIPTION="Aurora Apple Silicon startup-volume selector, NVRAM, BT sync and panel brightness"
HOMEPAGE="https://github.com/aurora-silicon/aurora-bless"

SRC_URI="https://codeload.github.com/aurora-silicon/aurora-bless/tar.gz/${COMMIT} -> ${PN}-${COMMIT}.tar.gz
	${CARGO_CRATE_URIS}"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

RDEPEND="
	net-wireless/bluez
	sys-apps/dbus
	sys-apps/systemd
	!sys-apps/asahi-bless
	!sys-apps/asahi-nvram
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"


src_compile() {
	cargo build --locked --release --offline \
		-p asahi-bless -p aurora-nvram -p aurora-btsync \
		-p aurora-panel-nits || die "cargo build failed"
}

src_test() {
	cargo test --locked --offline \
		-p asahi-bless -p apple-nvram -p aurora-nvram \
		-p aurora-btsync -p aurora-panel-nits || die "cargo test failed"
}

src_install() {
	local bin="target/release"

	newbin "${bin}/asahi-bless" aurora-bless
	dosym aurora-bless /usr/bin/asahi-bless

	newbin "${bin}/aurora-nvram" aurora-nvram
	dosym aurora-nvram /usr/bin/asahi-nvram

	newbin "${bin}/aurora-btsync" aurora-btsync
	dosym aurora-btsync /usr/bin/asahi-btsync
	systemd_dounit aurora-btsync/etc/systemd/system/aurora-btsync.service
	dosym aurora-btsync.service /usr/lib/systemd/system/asahi-btsync.service
	insinto /usr/lib/udev/rules.d
	doins aurora-btsync/etc/udev/rules.d/96-aurora-btsync.rules

	emake -C aurora-panel-nits install DESTDIR="${D}" PREFIX=/usr \
		BIN="${S}/${bin}/aurora-panel-nits"

	dodoc README.md NEO.md aurora-nvram/README.md aurora-btsync/README.md \
		aurora-panel-nits/README.md
}

# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora aurora-gamemode 0.1.13 (split from
# aurora-platform, shared sources.json pin). Ships /etc/gamemode.ini
# (covered by CONFIG_PROTECT, like Arch's backup= entry).

EAPI=8

COMMIT="ddf5285e116b3551ed2b025112f86effaadf299d"

DESCRIPTION="GameMode defaults for Apple silicon: games on the P cores, schedutil kept (Aurora)"
HOMEPAGE="https://github.com/aurora-silicon/aurora-platform"
SRC_URI="https://codeload.github.com/aurora-silicon/aurora-platform/tar.gz/${COMMIT} -> aurora-platform-${COMMIT}.tar.gz"
S="${WORKDIR}/aurora-platform-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

RDEPEND="games-util/gamemode"
DEPEND="${RDEPEND}"

src_compile() {
	# Nothing to build: the upstream Makefile's default target is
	# "install" itself, which portage's default src_compile would
	# run without DESTDIR. Installation happens in src_install.
	:;
}

src_install() {
	emake install-gamemode DESTDIR="${D}" PREFIX=/usr SYSCONFDIR=/etc
}

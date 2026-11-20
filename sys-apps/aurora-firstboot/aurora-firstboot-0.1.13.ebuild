# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora aurora-firstboot 0.1.13 (aurora-platform, shared
# sources.json pin). Per-install root encryption and Linux owner setup.
# The Arch package installs install-common + install-mkinitcpio; the
# upstream Makefile also ships install-dracut (97aurora-root), which
# is the Gentoo path taken here.

EAPI=8

COMMIT="ddf5285e116b3551ed2b025112f86effaadf299d"

DESCRIPTION="Aurora per-install root encryption and Linux owner setup"
HOMEPAGE="https://github.com/aurora-silicon/aurora-platform"
SRC_URI="https://codeload.github.com/aurora-silicon/aurora-platform/tar.gz/${COMMIT} -> aurora-platform-${COMMIT}.tar.gz"
S="${WORKDIR}/aurora-platform-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

RDEPEND="
	app-admin/sudo
	app-shells/bash
	dev-lang/python
	sys-apps/kbd
	sys-apps/shadow
	sys-apps/systemd
	sys-apps/util-linux
	sys-fs/btrfs-progs
	>=sys-fs/cryptsetup-2.8
	sys-kernel/dracut
	sys-process/procps
"
DEPEND="${RDEPEND}"

src_compile() {
	# Nothing to build: the upstream Makefile's default target is
	# "install" itself, which portage's default src_compile would
	# run without DESTDIR. Installation happens in src_install.
	:;
}

src_install() {
	emake install-common install-dracut DESTDIR="${D}" PREFIX=/usr

	insinto /usr/lib/systemd/system-preset
	doins "${FILESDIR}/90-aurora-firstboot.preset"
}

pkg_postinst() {
	elog "Enable with:  systemctl preset aurora-firstboot.service"
	elog "Rebuild the initramfs (dracut --force) so the 97aurora-root"
	elog "module is included before the first real boot."
}

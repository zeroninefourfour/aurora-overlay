# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora aurora-secboot 0.1.13 (split from
# aurora-platform, shared sources.json pin). Signed unified kernel
# images for the Aurora secure boot path. The Arch package also
# installs install-secboot-mkinitcpio (a mkinitcpio post hook); the
# distro-agnostic path — the kernel-install plugin
# 92-aurora-secboot.install from install-secboot — is what Gentoo
# uses, so the mkinitcpio hook is deliberately not installed.
# /etc/aurora/secboot.conf is covered by CONFIG_PROTECT.

EAPI=8

COMMIT="ddf5285e116b3551ed2b025112f86effaadf299d"

DESCRIPTION="Signed unified kernel images for the Aurora secure boot path"
HOMEPAGE="https://github.com/aurora-silicon/aurora-platform"
SRC_URI="https://codeload.github.com/aurora-silicon/aurora-platform/tar.gz/${COMMIT} -> aurora-platform-${COMMIT}.tar.gz"
S="${WORKDIR}/aurora-platform-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

# ukify is part of sys-apps/systemd (systemd-ukify in Arch terms).
RDEPEND="
	app-crypt/sbsigntools
	dev-lang/python
	dev-libs/openssl
	sys-apps/systemd
"
DEPEND="${RDEPEND}"

src_compile() {
	# Nothing to build: the upstream Makefile's default target is
	# "install" itself, which portage's default src_compile would
	# run without DESTDIR. Installation happens in src_install.
	:;
}

src_install() {
	emake install-secboot DESTDIR="${D}" PREFIX=/usr SYSCONFDIR=/etc

	insinto /usr/lib/systemd/system-preset
	doins "${FILESDIR}/90-aurora-secboot.preset"
}

pkg_postinst() {
	elog "Enable key adoption with:"
	elog "  systemctl preset aurora-secboot-adopt.service"
	elog "Configuration: /etc/aurora/secboot.conf"
}

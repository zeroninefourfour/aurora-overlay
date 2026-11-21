# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora aurora-boot 20261018. Like aurora-firmware,
# the payload is files copied byte-identically from alarm-aurora
# (sha256s match its PKGBUILD). The Arch-specific pieces are handled
# the Gentoo way:
#   * the three mkinitcpio install hooks (aurora-usb4,
#     aurora-display, aurora-early-kms) are ported to one dracut
#     module, 98aurora-early-kms (files/dracut-module-setup.sh);
#   * the mkinitcpio.conf.d snippet's COMPRESSION="zstd" becomes a
#     dracut.conf.d drop-in (its HOOKS order has no dracut meaning —
#     module order comes from dracut dependencies; the aurora-root
#     and aurora-vendor hooks are the dracut modules shipped by
#     aurora-firstboot and aurora-firmware);
#   * the libalpm hooks (rebuild initramfs / grub.cfg after package
#     transactions) are NOT ported: Gentoo has no pacman, and the
#     equivalent actions are the admin's dracut/grub-mkconfig runs;
#   * the Arch keyring pieces (initialize-keyring,
#     aurora-alarm-keyring.service and its presets/drop-in) are NOT
#     ported: they maintain the pacman keyring, which does not exist
#     on Gentoo. The aurora-keyring / asahi-alarm-keyring deps go
#     with them, as does mkinitcpio itself.

EAPI=8

# No upstream tarball: the payload is entirely in FILESDIR.

DESCRIPTION="Aurora boot integration: early-KMS initrd display, GRUB defaults, image preset"
HOMEPAGE="https://github.com/aurora-silicon/alarm-aurora"
S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

RDEPEND="
	sys-apps/asahi-scripts
	sys-apps/aurora-firstboot
	sys-apps/aurora-power-budget
	sys-apps/speakersafetyd-aurora-profiles
	sys-boot/aura
	sys-boot/grub
	sys-boot/uboot-aurora
	sys-firmware/aurora-firmware
	sys-kernel/dracut
"

src_install() {
	exeinto /usr/libexec/aurora
	doexe "${FILESDIR}/aurora-early-kms" "${FILESDIR}/aurora-early-kms-wait"

	insinto /usr/lib/aurora/initrd
	doins "${FILESDIR}/aurora-early-kms.service" \
		"${FILESDIR}/aurora-kms-handover.service"

	insinto /etc/default/grub.d
	doins "${FILESDIR}/40-aurora-console.cfg" "${FILESDIR}/45-aurora-mte.cfg"

	insinto /usr/lib/systemd/system-preset
	doins "${FILESDIR}/80-aurora-image.preset"

	exeinto /usr/lib/dracut/modules.d/98aurora-early-kms
	newexe "${FILESDIR}/dracut-module-setup.sh" module-setup.sh

	insinto /etc/dracut.conf.d
	newins "${FILESDIR}/aurora-dracut.conf" aurora.conf
}

pkg_postinst() {
	elog "Rebuild the initramfs (dracut --force) to pick up the"
	elog "98aurora-early-kms module, and re-run grub-mkconfig to"
	elog "pick up the /etc/default/grub.d snippets."
	elog "The image preset (units Aurora images keep off) applies"
	elog "with:  systemctl preset-all"
}

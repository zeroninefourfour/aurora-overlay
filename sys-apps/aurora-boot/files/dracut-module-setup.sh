#!/bin/bash
# SPDX-License-Identifier: MIT
# Dracut port of alarm-aurora's aurora-usb4 + aurora-display +
# aurora-early-kms mkinitcpio hooks: the USB4/Thunderbolt router,
# the display chain with its PMP, and the early-KMS coldplug units,
# so the display comes up in the initrd ahead of the general coldplug
# (an encrypted root otherwise holds the display gate back until it
# gives up, and every external display stays off for the whole boot).

depends() {
	echo udev-rules systemd
	return 0
}

install() {
	inst_multiple bash udevadm sleep
	inst_script /usr/libexec/aurora/aurora-early-kms \
		/usr/libexec/aurora/aurora-early-kms
	inst_script /usr/libexec/aurora/aurora-early-kms-wait \
		/usr/libexec/aurora/aurora-early-kms-wait
	inst_simple /usr/lib/aurora/initrd/aurora-early-kms.service \
		/usr/lib/systemd/system/aurora-early-kms.service
	mkdir -p "${initdir}/usr/lib/systemd/system/sysinit.target.wants"
	ln_r ../aurora-early-kms.service \
		/usr/lib/systemd/system/sysinit.target.wants/aurora-early-kms.service
	inst_simple /usr/lib/aurora/initrd/aurora-kms-handover.service \
		/usr/lib/systemd/system/aurora-kms-handover.service
	mkdir -p "${initdir}/usr/lib/systemd/system/initrd.target.wants"
	ln_r ../aurora-kms-handover.service \
		/usr/lib/systemd/system/initrd.target.wants/aurora-kms-handover.service
}

installkernel() {
	# The mkinitcpio hooks mark these optional ("name?"); they are
	# named explicitly so a machine whose autodetect ran elsewhere
	# still gets the full chain.
	instmods thunderbolt_apple \
		apple-pmp mux-apple-display-crossbar appledrm \
		i2c-pasemi-platform phy-apple-atc phy-ti-cd2e22 tps6598x \
		phy-apple-t6040-usb2 phy-apple-dptx
}

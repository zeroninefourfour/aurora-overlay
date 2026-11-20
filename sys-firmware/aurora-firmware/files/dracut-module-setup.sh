#!/bin/bash
# SPDX-License-Identifier: MIT
# Dracut port of alarm-aurora's mkinitcpio "aurora-vendor" hook:
# extract vendor firmware from the ESP and admit Apple peripherals
# in the systemd initrd (keyboard/trackpad before the root prompt).

depends() {
	echo udev-rules systemd
	return 0
}

install() {
	inst_multiple bash mount umount mkdir tr cpio grep modprobe udevadm
	inst_simple /usr/lib/modprobe.d/aurora-firmware-order.conf \
		/usr/lib/modprobe.d/aurora-firmware-order.conf
	inst_script /usr/libexec/aurora/peripheral-firmware \
		/usr/libexec/aurora/peripheral-firmware
	inst_script /usr/libexec/aurora/load-vendor-firmware \
		/usr/libexec/aurora/load-vendor-firmware
	inst_simple /usr/lib/aurora/initrd/aurora-vendor-firmware.service \
		/usr/lib/systemd/system/aurora-vendor-firmware.service
	mkdir -p "${initdir}/usr/lib/systemd/system/initrd.target.wants"
	ln_r ../aurora-vendor-firmware.service \
		/usr/lib/systemd/system/initrd.target.wants/aurora-vendor-firmware.service
}

installkernel() {
	# The blacklisted drivers from aurora-firmware-order.conf: present
	# in the image, but only loaded explicitly by the admission script
	# once the firmware search path points at the extracted vendorfw.
	instmods aop mt7932-fullmac mt7932_bt_pcie dockchannel-hid vfat
}

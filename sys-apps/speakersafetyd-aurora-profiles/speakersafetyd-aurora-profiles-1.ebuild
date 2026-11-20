# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora speakersafetyd-aurora-profiles 1. Payload is
# the four files in FILESDIR, copied byte-identically from
# alarm-aurora (sha256s match its PKGBUILD):
#   j616.conf  — MacBook Pro 16" (M4 Pro/Max, J616): J316 values with
#                the J616 V/I sense layout
#   j575c.conf — Mac Studio (M4 Max, J575c): j575 values with the AOP
#                stream's twelve-channel sense. NOTE: upstream says
#                this profile needs a speakersafetyd that tries the
#                machine's own file before its family's.
#   96-speakersafetyd-aurora.rules — udev rules
#   50-aurora-warm-restart.conf — a restart within the same boot
#                starts from the worst-case temperature
# The M2 Air's own profiles (j413/j415) ship inside speakersafetyd
# itself; this package covers the Aurora-added machines.

EAPI=8

# No upstream tarball: the payload is entirely in FILESDIR.
S="${WORKDIR}"

DESCRIPTION="speakersafetyd profiles for Aurora-supported Macs and warm restarts"
HOMEPAGE="https://github.com/aurora-silicon/alarm-aurora"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

RDEPEND=">=sys-apps/speakersafetyd-2.0.1"

src_install() {
	insinto /usr/share/speakersafetyd/apple
	doins "${FILESDIR}/j616.conf" "${FILESDIR}/j575c.conf"

	insinto /usr/lib/udev/rules.d
	doins "${FILESDIR}/96-speakersafetyd-aurora.rules"

	insinto /usr/lib/systemd/system/speakersafetyd.service.d
	doins "${FILESDIR}/50-aurora-warm-restart.conf"
}

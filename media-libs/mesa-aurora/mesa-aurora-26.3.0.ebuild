# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Port of alarm-aurora mesa-aurora 26.3.0 (shared sources.json pin,
# commit d4ad4a4d). The tree is matched to the DRM UAPI of the Aurora
# kernel (aurora-sources), which is why this is a pinned snapshot and
# not ::gentoo's media-libs/mesa.
#
# The defining property of the Aurora build: the native Asahi Gallium
# and Honeykrisp Vulkan drivers link NEITHER LLVM nor SPIRV-Tools.
# Arch moves both runtimes under the drivers (llvm-libs changes soname
# every major), so a Mesa linked against them loses the GPU on every
# LLVM bump until rebuilt. Asahi needs LLVM only to precompile its CL
# shaders, so — like ::gentoo's mesa/mesa_clc split — the compilers
# live in dev-util/mesa_clc (same pin) and this package builds with
# -Dllvm=disabled -Dmesa-clc=system -Dprecomp-compiler=system.
# src_install re-checks the invariant: no installed .so may carry a
# NEEDED entry for libLLVM or libSPIRV-Tools.
#
# alarm splits two more packages out of its LLVM-linked tools tree:
# opencl-rusticl-aurora and vulkan-lavapipe-aurora. They are not ported
# yet (see docs/migration-table.md); this package is the native GL +
# Honeykrisp stack only. mesa-aurora-fex-guest is a separate package.

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

# Crate subprojects of this exact tree (subprojects/*-rs.wrap). The
# Honeykrisp Vulkan driver is Rust; meson resolves these wraps from
# subprojects/packagecache, which src_unpack fills from DISTDIR.
CRATES="
	bitflags@2.9.1
	cfg-if@1.0.0
	equivalent@1.0.1
	errno@0.3.12
	hashbrown@0.14.1
	indexmap@2.2.6
	libc@0.2.185
	log@0.4.27
	mach2@0.7.0
	once_cell@1.8.0
	paste@1.0.14
	pest@2.8.0
	pest_derive@2.8.0
	pest_generator@2.8.0
	pest_meta@2.8.0
	proc-macro2@1.0.86
	quote@1.0.35
	remain@0.2.12
	roxmltree@0.20.0
	rustc-hash@2.1.1
	rustix@1.1.4
	syn@2.0.87
	thiserror@2.0.11
	thiserror-impl@2.0.11
	ucd-trie@0.1.6
	unicode-ident@1.0.12
	windows-link@0.2.0
	windows-sys@0.61.1
	xml@1.2.1
	zerocopy@0.8.13
	zerocopy-derive@0.8.13
"

RUST_MIN_VER="1.85.0"

inherit cargo meson python-any-r1

COMMIT="d4ad4a4dce6d1d23ecd897d6d73fadf9ab618614"

DESCRIPTION="Aurora Asahi Gallium, Zink and Honeykrisp drivers (pinned mesa)"
HOMEPAGE="https://github.com/aurora-silicon/mesa"
SRC_URI="https://codeload.github.com/aurora-silicon/mesa/tar.gz/${COMMIT} -> mesa-aurora-${PV}.tar.gz
	${CARGO_CRATE_URIS}"
S="${WORKDIR}/mesa-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"
IUSE="+X +lm-sensors test +vulkan +wayland"
RESTRICT="!test? ( test )"

RDEPEND="
	!media-libs/mesa
	dev-libs/expat
	>=virtual/zlib-1.2.8:=
	app-arch/zstd:=
	media-libs/libglvnd
	virtual/libudev:=
	x11-libs/libdrm
	lm-sensors? ( sys-apps/lm-sensors:= )
	vulkan? (
		media-libs/libdisplay-info:=
		media-libs/vulkan-loader
		x11-libs/xcb-util-keysyms
	)
	wayland? ( dev-libs/wayland )
	X? (
		x11-libs/libX11
		x11-libs/libxcb:=
		x11-libs/libXext
		x11-libs/libXfixes
		x11-libs/libXrandr
		x11-libs/libxshmfence
		x11-libs/libXxf86vm
	)
"
DEPEND="${RDEPEND}
	vulkan? ( dev-util/vulkan-headers )
	wayland? ( >=dev-libs/wayland-protocols-1.41 )
	X? ( x11-base/xorg-proto )
"
BDEPEND="
	~dev-util/mesa_clc-${PV}[video_cards_asahi]
	${PYTHON_DEPS}
	$(python_gen_any_dep "
		>=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]
		dev-python/packaging[\${PYTHON_USEDEP}]
		dev-python/pyyaml[\${PYTHON_USEDEP}]
	")
	dev-util/bindgen
	dev-util/cbindgen
	virtual/pkgconfig
	vulkan? ( dev-util/glslang )
"

python_check_deps() {
	python_has_version -b ">=dev-python/mako-0.8.0[${PYTHON_USEDEP}]" &&
	python_has_version -b "dev-python/packaging[${PYTHON_USEDEP}]" &&
	python_has_version -b "dev-python/pyyaml[${PYTHON_USEDEP}]" || return 1
}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_unpack() {
	default

	# Fill meson's package cache with this tree's crate subprojects
	# (same trick as ::gentoo's mesa): the .crate files in DISTDIR are
	# the wraps' .tar.gz sources under a different name.
	mkdir -p "${S}"/subprojects/packagecache || die
	local i
	for i in ${CRATES}; do
		i=${i/@/-}
		ln -s "${DISTDIR}/${i}.crate" \
			"${S}/subprojects/packagecache/${i}.tar.gz" || die
	done
}

src_configure() {
	export MESA_GIT_SHA1_OVERRIDE=${COMMIT}

	local platforms=()
	use X && platforms+=( x11 )
	use wayland && platforms+=( wayland )
	local platform_str
	platform_str=$(IFS=,; echo "${platforms[*]}")

	local emesonargs=(
		-Dplatforms=${platform_str}
		-Dgallium-drivers=asahi,zink,softpipe
		-Dvulkan-drivers=$(usex vulkan asahi '')
		-Degl=enabled
		-Dgbm=enabled
		-Dglx=dri
		-Dgles1=enabled
		-Dgles2=enabled
		-Dglvnd=enabled
		-Dvideo-codecs=all
		-Dvulkan-layers=
		-Dexpat=enabled
		-Dzstd=enabled
		-Dlmsensors=$(usex lm-sensors enabled disabled)
		-Dlibunwind=disabled
		-Dvalgrind=disabled
		# The Aurora invariant: no LLVM/SPIRV-Tools in the native
		# drivers; shader precompilation uses the system compilers
		# from dev-util/mesa_clc (same pin).
		-Dllvm=disabled
		-Dspirv-tools=disabled
		-Dmesa-clc=system
		-Dprecomp-compiler=system
		-Dbuild-tests=$(usex test true false)
		-Db_ndebug=true
		-Db_pie=true
	)

	EMESON_BUILDTYPE=plain meson_src_configure
}

src_test() {
	meson_src_test

	if use vulkan; then
		# alarm's check: the Honeykrisp driver must carry this tree's
		# git identity ("Borealis" is the asahi vulkan codename).
		local vk_so
		vk_so=$(find "${BUILD_DIR}" -name 'libvulkan_asahi.so' | head -n 1)
		[[ -n ${vk_so} ]] || die "libvulkan_asahi.so not found in build dir"
		strings "${vk_so}" | grep -F "(git-${COMMIT:0:10}), Borealis" \
			|| die "libvulkan_asahi.so lacks the Aurora git version string"
	fi
}

src_install() {
	meson_src_install

	# alarm's other check, applied to the installed image: nothing in
	# the native GL/Vulkan stack may link the system LLVM or
	# SPIRV-Tools (see the header comment).
	local binary dependencies
	while IFS= read -r -d '' binary; do
		dependencies=$(LC_ALL=C readelf -d "${binary}") || die
		if grep -Eq 'NEEDED.*(libLLVM|libSPIRV-Tools)' <<<"${dependencies}"; then
			die "Unexpected compiler runtime dependency: ${binary#${D}}"
		fi
	done < <(find "${D}" -name '*.so*' -type f -print0)
}

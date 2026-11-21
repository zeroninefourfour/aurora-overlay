# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# mesa_clc + asahi_clc + vtn_bindgen2 built from the Aurora mesa tree
# (shared sources.json pin with media-libs/mesa-aurora). Follows
# ::gentoo's dev-util/mesa_clc split: the CL compilers link LLVM and
# libclc, so they live in this package and the packaged mesa uses the
# system copies (-Dmesa-clc=system -Dprecomp-compiler=system). That is
# what keeps the native Asahi GL/Vulkan drivers free of any LLVM or
# SPIRV-Tools runtime linkage, so an LLVM soname bump cannot leave the
# machine without a GPU before mesa is rebuilt.

EAPI=8

LLVM_COMPAT=( {18..22} )
PYTHON_COMPAT=( python3_{12..15} )

inherit llvm-r2 meson python-any-r1

COMMIT="d4ad4a4dce6d1d23ecd897d6d73fadf9ab618614"

DESCRIPTION="Aurora mesa CL compilers (mesa_clc, asahi_clc, vtn_bindgen2)"
HOMEPAGE="https://github.com/aurora-silicon/mesa"
SRC_URI="https://codeload.github.com/aurora-silicon/mesa/tar.gz/${COMMIT} -> mesa-aurora-26.3.0.tar.gz"
S="${WORKDIR}/mesa-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~arm64"

VIDEO_CARDS="asahi"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done
IUSE="${IUSE_VIDEO_CARDS} debug"
# The Aurora mesa exists for the Asahi drivers; its clc package
# without asahi_clc would not serve mesa-aurora, so default it on.
IUSE="+video_cards_asahi debug"

RDEPEND="
	dev-util/spirv-tools
	$(llvm_gen_dep '
		dev-util/spirv-llvm-translator:${LLVM_SLOT}
		llvm-core/clang:${LLVM_SLOT}=
		llvm-core/llvm:${LLVM_SLOT}=
		=llvm-runtimes/libclc-${LLVM_SLOT}*
	')
"
DEPEND="${RDEPEND}
	dev-libs/expat
	>=virtual/zlib-1.2.8:=
	x11-libs/libdrm
"
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_any_dep "
		>=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]
		dev-python/packaging[\${PYTHON_USEDEP}]
		dev-python/pyyaml[\${PYTHON_USEDEP}]
	")
	virtual/pkgconfig
"

python_check_deps() {
	python_has_version -b ">=dev-python/mako-0.8.0[${PYTHON_USEDEP}]" &&
	python_has_version -b "dev-python/packaging[${PYTHON_USEDEP}]" &&
	python_has_version -b "dev-python/pyyaml[${PYTHON_USEDEP}]" || return 1
}

pkg_setup() {
	llvm-r2_pkg_setup
	python-any-r1_pkg_setup
}

src_configure() {
	tools_enable video_cards_asahi asahi

	tools_list() {
		local tools="$(sort -u <<< "${1// /$'\n'}")"
		echo "${tools//$'\n'/,}"
	}

	PKG_CONFIG_PATH="$(get_llvm_prefix)/$(get_libdir)/pkgconfig"

	use debug && EMESON_BUILDTYPE=debug

	local emesonargs=(
		-Dallow-broken-lto=true
		-Dllvm=enabled
		-Dshared-llvm=enabled
		-Dmesa-clc=enabled
		-Dinstall-mesa-clc=true
		-Dprecomp-compiler=enabled
		-Dinstall-precomp-compiler=true
		-Dtools=$(tools_list "${TOOLS[*]}")

		-Dgallium-drivers=''
		-Dvulkan-drivers=''

		# Set platforms empty to avoid the default "auto" setting. If
		# platforms is empty meson.build will add surfaceless.
		-Dplatforms=''

		-Dglx=disabled
		-Dlibunwind=disabled
		-Dzstd=disabled

		-Db_ndebug=$(usex debug false true)
	)

	meson_src_configure
}

src_install() {
	dobin "${BUILD_DIR}"/src/compiler/clc/mesa_clc
	dobin "${BUILD_DIR}"/src/compiler/spirv/vtn_bindgen2
	use video_cards_asahi && dobin "${BUILD_DIR}"/src/asahi/clc/asahi_clc
}

# $1 - VIDEO_CARDS flag (check skipped for "--")
# other args - names of tools to enable
tools_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		TOOLS+=("$@")
	fi
}

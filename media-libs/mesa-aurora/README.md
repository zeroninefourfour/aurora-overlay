# mesa-aurora — why there is no ebuild here yet

Aurora Mesa is a *pin*, not a fork with patches: `aurora-silicon/mesa`
commit `d4ad4a4dce6d1d23ecd897d6d73fadf9ab618614`, version 26.3.0,
matched to the DRM UAPI in the pinned Aurora kernel.

The other Aurora distros build it with:

```
-Dplatforms=x11,wayland
-Dgallium-drivers=asahi,zink,softpipe
-Dvulkan-drivers=asahi          # Honeykrisp
-Dglvnd=enabled -Degl=enabled -Dgbm=enabled
-Dgallium-rusticl=true          # in a separate LLVM-linked build tree
```

and, critically, the *installed* GL/Vulkan binaries must NOT link
`libLLVM` or `libSPIRV-Tools` (a two-tree build: first build the CL
compilers with LLVM, then rebuild Mesa against them with
`-Dllvm=disabled`). Arch/Fedora learned this the hard way: a Mesa
linked against the old LLVM soname leaves the machine with no GPU
after an LLVM bump.

On Gentoo, `media-libs/mesa` in ::gentoo already builds the Asahi
Gallium driver and Honeykrisp Vulkan driver from a *release* Mesa.
So the Gentoo-correct way to ship the Aurora pin is one of:

1. **Preferred, short term:** use ::gentoo `media-libs/mesa` with
   `VIDEO_CARDS=asahi` — accept that it is not the Aurora pin, and
   only diverge if a real bug appears against the Aurora kernel UAPI.
2. **Pin-accurate:** copy ::gentoo's mesa ebuild (it is large and
   eclass-heavy) into this directory as `mesa-aurora`, point
   `SRC_URI` at the pinned codeload tarball, set
   `MESA_GIT_SHA1_OVERRIDE=d4ad4a4dce6d...`, and reproduce the
   two-tree LLVM isolation. This must be done on an arm64 Gentoo
   machine where the result can be test-built — it is not honestly
   writable blind, which is why it is not faked here.

Do NOT write a naive `meson setup` ebuild for Mesa: you will lose
::gentoo's multilib, video-card and ICD handling.

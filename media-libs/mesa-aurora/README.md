# mesa-aurora — ported 2026-11-21

`mesa-aurora-26.3.0.ebuild` in this directory is a real ebuild now.
Aurora Mesa is a *pin*, not a fork with patches: `aurora-silicon/mesa`
commit `d4ad4a4dce6d1d23ecd897d6d73fadf9ab618614`, version 26.3.0,
matched to the DRM UAPI in the pinned Aurora kernel.

## How the port is shaped

alarm-aurora builds one LLVM-linked "tools" tree (CL compilers +
Rusticl + lavapipe) and one native tree. Gentoo already has the same
split, so the port follows it:

- `dev-util/mesa_clc` 26.3.0 (this overlay, same tarball) builds
  `mesa_clc`, `vtn_bindgen2` and `asahi_clc` against LLVM/libclc.
- `media-libs/mesa-aurora` builds the native drivers with
  `-Dllvm=disabled -Dspirv-tools=disabled -Dmesa-clc=system
  -Dprecomp-compiler=system`, gallium `asahi,zink,softpipe`, vulkan
  `asahi` (Honeykrisp). It blocks `media-libs/mesa`.
- The invariant alarm checks in its `check()` — no installed `.so`
  may have a NEEDED entry for libLLVM or libSPIRV-Tools — runs at the
  end of `src_install` here, and `src_test` verifies the Honeykrisp
  version string `(git-d4ad4a4dce), Borealis`.

## Not yet ported from the alarm pkgbase

- `opencl-rusticl-aurora` and `vulkan-lavapipe-aurora` (they link LLVM
  at runtime by design and ship separately in alarm too).
- `mesa-aurora-fex-guest` (x86_64/i686 FEX guest layer).

## Verification status

Distfile sha256 matches the sources.json pin; both Manifests are
generated; `emerge -pv dev-util/mesa_clc media-libs/mesa-aurora`
resolves (77 packages) in the arm64 chroot. The full compile has NOT
been run under qemu (mesa is a multi-hour emulated build); like the
Rust packages in this overlay, it is expected to build natively on
real hardware first.

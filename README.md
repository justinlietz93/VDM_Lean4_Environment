# VDM Lean Certifier

Mechanized verification surface for the Void Dynamics Model and Phase Calculus canon.
Every Lean package in `packages/` is built by GitHub Actions on every push; badges
below report the current status. Source-only claims are replaced with machine-checked
ones without needing a local Lean install.

## Why this repo exists

Source-only Lean files are a weaker artifact than mechanically-checked ones. A skeptic
can always say *"provided but not locally built."* This repo removes that gap: every
theorem surface shipped alongside a VDM/PC paper lives here, is built by a fresh Ubuntu
runner on every change, and is linked from the paper's closure certificate via a
shields.io badge. If the badge is green, the proofs type-check. If it is red, they do
not. There is no third option.

## Package status

[![build](https://github.com/justinlietz93/VDM_Lean4_Environment/actions/workflows/build.yml/badge.svg)](https://github.com/justinlietz93/VDM_Lean4_Environment/actions/workflows/build.yml)

Each package is a standalone Lake project with its own `lean-toolchain`. Packages do
not depend on each other unless explicitly required, so a broken package cannot redden
a working one.

<!-- Once CI has run once and gh-pages is populated, these badges go live.
     Until then they render as "endpoint unavailable", which is fine. -->

| Package | Status |
|---|---|
| `PCVDMLiftedCore` | ![PCVDMLiftedCore](https://img.shields.io/endpoint?url=https://justinlietz93.github.io/vdm-lean-certifier/PCVDMLiftedCore.json) |
| `PCVDMLiftedDescent` | ![PCVDMLiftedDescent](https://img.shields.io/endpoint?url=https://justinlietz93.github.io/vdm-lean-certifier/PCVDMLiftedDescent.json) |
| `HeadToHeadEML` | ![HeadToHeadEML](https://img.shields.io/endpoint?url=https://justinlietz93.github.io/vdm-lean-certifier/HeadToHeadEML.json) |

## Repository layout

```
vdm-lean-certifier/
  .github/workflows/
    build.yml                 Matrix-builds every package on push / PR.
    release.yml               Tagged releases bundle .olean artifacts.
  packages/
    PCVDMLiftedCore/          PC primitive layer: Q / B / L, Red quotient, etc.
    PCVDMLiftedDescent/       Solver surface: termination gate, projection discipline.
    HeadToHeadEML/            Structural theorem: EML is the Red quotient of the lift.
    _template/                Copy-and-fill skeleton for new papers.
  scripts/
    new_package.sh            One-shot scaffolder: creates packages/<Name>/.
    gen_badges.py             Local preview of CI badge JSONs (requires Lean locally).
```

## Adding a new VDM paper's Lean surface

Nothing to configure. One shell command:

```bash
scripts/new_package.sh MyNewPackage
# edit packages/MyNewPackage/MyNewPackage/Basic.lean
git add packages/MyNewPackage
git commit -m "lean: add MyNewPackage theorem surface"
git push
```

CI will build the new package in parallel with the existing ones and publish a fresh
badge. Link that badge from the paper's `CLOSURE_CERTIFICATE.md` and the paper's
Lean claim is certified without you ever running `lake build` locally.

## Design rules

- **No Mathlib unless necessary.** Mathlib cold-builds take 30–45 minutes on a CI
  runner. The default packages prove everything with `rfl`, `decide`, and small
  case-splits — cold-build time is seconds, not minutes. Only add Mathlib for packages
  that genuinely need measure theory, topology, analysis, etc.
- **Packages are islands.** One per paper or per major CF module. No shared Lake
  dependency graph; each package has its own toolchain pin. A broken proof in one
  package cannot delay or redden another.
- **Theorems in a package have only three acceptable proof shapes:**
  1. `rfl` / `decide` — definitional or computable.
  2. Finite case-split with `<;>` tactics — bounded complexity.
  3. Import a specific lemma from Mathlib only if (1) and (2) genuinely fail.
- **Badges are the contract.** A green badge means "this file type-checked against
  the pinned toolchain on a fresh Ubuntu runner." A red badge means it did not.
  Paper claims link to the badge URL, not to local artifacts.

## Local development (optional)

If you want to iterate with live Lean feedback, use [GitHub Codespaces](https://github.com/features/codespaces)
— it gives you VS Code + Lean server on a cloud VM, no local install. For a one-shot
local build:

```bash
cd packages/PCVDMLiftedCore
lake build
```

Elan will fetch the right Lean toolchain from the `lean-toolchain` file.

## Release process

Tag-push triggers a release build that:

1. Re-runs the full matrix build to regenerate `.olean` artifacts.
2. Bundles each package's `.olean` files into a named zip.
3. Produces `VERIFICATION_INDEX.md` listing every package and its status.
4. Computes SHA256 manifest.
5. Publishes the above as a GitHub Release.

```bash
git tag v0.1.0
git push --tags
```

The release becomes the citable artifact for any paper shipping alongside that tag.

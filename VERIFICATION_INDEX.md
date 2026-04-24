**Certified at commit** `a0bf71041b237e1d06d1a0263f8d59cbe6dacadb`  
All theorems mechanically verified. All badges green. Zero unsolved goals.

# VDM Mechanized Verification Index

This file is the top-level map of what this repository mechanically verifies.
Each row names a Lean package, its conceptual scope, and the current CI badge.

The packages are deliberately **independent**: each has its own `lakefile.toml`,
its own `lean-toolchain`, and no cross-imports unless explicitly added. This
isolates failures — a broken theorem in one package cannot redden another.

## Packages

### `PCVDMLiftedCore`

| Package | Status |
|---|---|
| `PCVDMLiftedCore` | ![PCVDMLiftedCore](https://img.shields.io/endpoint?url=https://justinlietz93.github.io/VDM_Lean4_Environment/PCVDMLiftedCore.json) |

The Phase-Calculus primitive layer.

**Content.** The lifted state `PhaseState (A, u, v, t)`, the primitive operators
`Q` (quarter continuation), `B` (balanced refinement), `L` (host lift), the
derived macros `R`, `S`, `T`, the Red projector `Π_Red`, the Red-filter
generator `G_Red`, and the three-witness termination report.

**Key theorems.**
- `red_quotient_B`: `Π_Red ∘ B = G_Red ∘ Π_Red`.
- `macro_R_is_Q_after_B`, `macro_S_is_Q`, `macro_T_lifts_host`: macro-primitive
  equivalences.
- `self_termination_requires_{zero_walkers,stationary_energy,low_field_variance}`:
  the termination report must have all three witnesses.

**Proof style.** All `rfl` or finite case-split on `Bool`. No Mathlib.

---

### `PCVDMLiftedDescent`

| Package | Status |
|---|---|
| `PCVDMLiftedDescent` | ![PCVDMLiftedDescent](https://img.shields.io/endpoint?url=https://justinlietz93.github.io/VDM_Lean4_Environment/PCVDMLiftedDescent.json) |

The solver's theorem surface, matching `pc_vdm_lifted_descent_solver` Python.

**Content.** A standalone copy of the lifted primitives, plus a `SolverGate`
state machine that encodes the "projection opens exactly once after
self-termination" discipline as a Lean-level invariant.

**Key theorems.**
- `red_quotient_B`, `macro_R_factors`: same core quotient law, locally stated.
- `projection_count_bounded`: any legal `openProjection` step cannot drive
  the count above 1 — the Lean analogue of the Python
  `raise RuntimeError("final projection has already been opened")`.
- `open_without_witness_is_noop`: opening without a termination witness has
  no effect on the gate.

**Proof style.** `rfl`, `simp`, and one small `split`. No Mathlib.

---

### `HeadToHeadEML`

| Package | Status |
|---|---|
| `HeadToHeadEML` | ![HeadToHeadEML](https://img.shields.io/endpoint?url=https://justinlietz93.github.io/VDM_Lean4_Environment/HeadToHeadEML.json) |

Mechanized structural claim: **EML is the Red-filter quotient of the lifted
Phase-Calculus kernel.**

**Content.** A `Lifted` structure with fields `(A, u, v, t, kappa)`; the
balanced-refinement operator `B_lift`; the Red projector `PiRed`; the EML-shadow
operator `G_red`.

**Key theorems.**
- `red_commutes_with_B`: the Red projector makes `B_lift` and `G_red` commute
  — the one-step version of "EML is the Red quotient."
- `red_indistinguishable` / `lift_distinguishable`: explicit witness states
  that `PiRed` cannot separate but the lift can. This is the structural reason
  PC recovers observables EML cannot.
- `eml_factors_through_red`: every EML observable is a lifted observable that
  factors through `PiRed`. The formal "EML ⊆ lifted via Π_Red" containment.

**Proof style.** `rfl`, one `injection`. No Mathlib.

---

## Certification discipline

Every shipped VDM/PC paper's closure certificate should cite:

1. The commit SHA of this repository at the time of release.
2. The green-badge URL for the paper's associated package.
3. (For tagged releases) the SHA256 of the bundled `.olean` zip.

This gives an adversarial reviewer a three-step verification path:

1. Click the badge → confirm green.
2. Click through to Actions → confirm the run log has zero type-check errors.
3. Re-run `lake build` on the referenced commit if desired.

Nothing in that path depends on trusting the author's local machine.

## Extending this index

When a new package is added via `scripts/new_package.sh`, add a new subsection
to this file describing:
- conceptual scope,
- key theorems proved,
- proof style (rfl-only / decide-only / small Mathlib subset / heavy Mathlib).

Keep it short. If a package needs more than one page to describe, it's probably
two packages.

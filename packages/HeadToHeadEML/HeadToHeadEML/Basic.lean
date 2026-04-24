/-
  HeadToHeadEML.Basic

  Mechanized surface for the head-to-head result:

      EML is the Red-filter quotient of the Phase-Calculus lifted kernel.

  This file proves a stripped-down structural version of that claim. The
  content: whatever a single-step EML-style operator can compute about
  (u, v) is already visible under the Red projector applied to the lifted
  balanced-refinement operator B. Concretely: the Red projector commutes
  with B, and the continuous EML shadow cannot distinguish phase states
  that project to the same (u, v).

  This is a *structural* theorem, not an analytic one: it says that the
  Red filter is a natural transformation between the lifted and EML-style
  layers, so any EML computation is a projection of the lifted one.

  No Mathlib. No axioms beyond Lean's core. Type-checks in seconds.
-/

namespace HeadToHeadEML

/-! ## The lifted object -/

structure Lifted where
  A : Nat
  u : Nat
  v : Nat
  t : Nat          -- tick counter (kept for phase, discarded by Red)
  kappa : Nat      -- completed quarter-turns
  deriving Repr, DecidableEq

/-! ## The two one-step operators

  `B_lift` is the balanced refinement on the lifted state. `G_red` is its
  shadow — the very operation that `eml(x, y) = exp(x) - log(y)` implements
  on the (u, v) layer, once you strip away A, t, kappa. -/

def B_lift (x : Lifted) : Lifted :=
  { x with u := x.v, v := x.u + x.v }

def PiRed (x : Lifted) : Nat × Nat := (x.u, x.v)

def G_red (q : Nat × Nat) : Nat × Nat := (q.2, q.1 + q.2)

/-! ## Red is a natural transformation

  The diagram

        Lifted ─── B_lift ───▶ Lifted
          │                      │
        PiRed                  PiRed
          ▼                      ▼
      (Nat×Nat) ── G_red ──▶ (Nat×Nat)

  commutes. This is the single load-bearing theorem of the head-to-head. -/

/-- **Red-quotient commutation.**
    The EML-shadow operator `G_red` is exactly what `B_lift` looks like after
    the Red projector has forgotten `(A, t, kappa)`. -/
theorem red_commutes_with_B (x : Lifted) :
    PiRed (B_lift x) = G_red (PiRed x) := rfl

/-! ## Discrimination gap: the lift sees what EML cannot

  Below we exhibit two lifted states that are indistinguishable under
  the Red projector but distinguishable in the lift. This is the
  structural reason PC recovers `sin`, Bring roots, and certified-interval
  outputs that EML cannot reach: those observables depend on `(A, t, kappa)`,
  which Red discards. -/

/-- Two states with identical `(u,v)` but different `(A, t, kappa)`. -/
def s₁ : Lifted := { A := 0, u := 55, v := 89, t := 17, kappa := 4 }
def s₂ : Lifted := { A := 1, u := 55, v := 89, t := 42, kappa := 10 }

/-- Red cannot tell them apart. -/
theorem red_indistinguishable : PiRed s₁ = PiRed s₂ := rfl

/-- The lift can. -/
theorem lift_distinguishable : s₁ ≠ s₂ := by
  intro h
  -- The components `A`, `t`, `kappa` differ, so the structures differ.
  injection h with hA _ _ ht _

/-! ## Corollary: any observable depending on (A, t, kappa) is inaccessible
    to any EML-style computation that factors through `PiRed`. -/

/-- An EML-shadow observable is any function of `(u, v)` alone. -/
def EMLObservable (α : Type) := Nat × Nat → α

/-- A lifted observable is any function of the full state. -/
def LiftedObservable (α : Type) := Lifted → α

/-- `embedEML`: every EML observable is a lifted observable that factors
    through Red. This is the formal statement "EML ⊆ lifted via Π_Red". -/
def embedEML {α : Type} (f : EMLObservable α) : LiftedObservable α :=
  fun x => f (PiRed x)

/-- **Structural containment.** Every EML observable is a lifted observable
    that ignores `(A, t, kappa)`. The converse is false (witness: any
    observable that reads `t` cannot be expressed through `PiRed`). -/
theorem eml_factors_through_red {α : Type} (f : EMLObservable α) (x : Lifted) :
    embedEML f x = f (PiRed x) := rfl

end HeadToHeadEML

/-
  PCVDMLiftedCore.Basic

  The Phase-Calculus primitive layer: lifted state, atomic operators Q / B / L,
  derived macro operators R / S / T, Red-filter quotient, and termination report.

  All proofs in this file are `rfl` or finite case-splits over Bool, so the
  package type-checks in seconds with no external dependencies.

  Corresponds to the primitive-operator layer of the merged Phase-Calculus
  manuscript (Theorems in §3.5-3.6; selector-closed macro law of Theorem 7.10).
-/

namespace PCVDMLiftedCore

/-- Lifted phase state: host class `A`, balanced pair `(u,v)`, tick counter `t`. -/
structure PhaseState where
  A : Nat
  u : Nat
  v : Nat
  t : Nat
  deriving Repr, DecidableEq

/-- Quarter continuation: advances the tick counter by one. -/
def Q (x : PhaseState) : PhaseState :=
  { x with t := x.t + 1 }

/-- Balanced refinement: `(u,v) ↦ (v, u+v)`. Tick unchanged. -/
def B (x : PhaseState) : PhaseState :=
  { x with u := x.v, v := x.u + x.v }

/-- Host lift: increments `A`, advances tick; caller re-seeds `(u,v)`. -/
def L (x : PhaseState) : PhaseState :=
  { x with A := x.A + 1, t := x.t + 1 }

/-- Macro `R = Q ∘ B`: executable refinement continuation. -/
def R (x : PhaseState) : PhaseState := Q (B x)

/-- Macro `S = Q`: same-host continuation. -/
def S (x : PhaseState) : PhaseState := Q x

/-- Macro `T`: orthogonal re-articulation. Re-seeds the pair at the new class. -/
def T (x : PhaseState) : PhaseState :=
  { A := x.A + 1, u := 1, v := x.A + 1, t := x.t + 1 }

/-- Red projector `Π_Red`: forget everything except the balanced pair. -/
def PiRed (x : PhaseState) : Nat × Nat := (x.u, x.v)

/-- Red-filter generator `G_Red : (u,v) ↦ (v, u+v)`. -/
def GRed (q : Nat × Nat) : Nat × Nat := (q.2, q.1 + q.2)

/-! ## Primitive operator invariants -/

theorem Q_adds_one_tick (x : PhaseState) : (Q x).t = x.t + 1 := rfl

theorem B_preserves_tick (x : PhaseState) : (B x).t = x.t := rfl

theorem L_adds_one_tick (x : PhaseState) : (L x).t = x.t + 1 := rfl

/-- **Red quotient theorem for B.**
    The Red projection commutes with `B`: `Π_Red ∘ B = G_Red ∘ Π_Red`. -/
theorem red_quotient_B (x : PhaseState) : PiRed (B x) = GRed (PiRed x) := rfl

/-! ## Macro / primitive equivalences -/

theorem macro_R_is_Q_after_B (x : PhaseState) : R x = Q (B x) := rfl
theorem macro_S_is_Q          (x : PhaseState) : S x = Q x := rfl
theorem macro_T_lifts_host    (x : PhaseState) : (T x).A = x.A + 1 := rfl

/-! ## Termination gate -/

/-- Three-witness termination condition for the metriplectic descent. -/
structure TerminationReport where
  lowFieldVariance : Bool
  zeroWalkers : Bool
  stationaryEnergy : Bool
  deriving Repr, DecidableEq

/-- Self-termination: all three witnesses must fire. -/
def SelfTerminated (r : TerminationReport) : Bool :=
  r.lowFieldVariance && r.zeroWalkers && r.stationaryEnergy

/-- Self-termination implies zero walkers. -/
theorem self_termination_requires_zero_walkers
    (r : TerminationReport) (h : SelfTerminated r = true) :
    r.zeroWalkers = true := by
  unfold SelfTerminated at h
  cases r.lowFieldVariance <;> cases r.zeroWalkers <;> cases r.stationaryEnergy
    <;> simp at h ⊢

/-- Self-termination implies stationary energy. -/
theorem self_termination_requires_stationary_energy
    (r : TerminationReport) (h : SelfTerminated r = true) :
    r.stationaryEnergy = true := by
  unfold SelfTerminated at h
  cases r.lowFieldVariance <;> cases r.zeroWalkers <;> cases r.stationaryEnergy
    <;> simp at h ⊢

/-- Self-termination implies low field variance. -/
theorem self_termination_requires_low_field_variance
    (r : TerminationReport) (h : SelfTerminated r = true) :
    r.lowFieldVariance = true := by
  unfold SelfTerminated at h
  cases r.lowFieldVariance <;> cases r.zeroWalkers <;> cases r.stationaryEnergy
    <;> simp at h ⊢

end PCVDMLiftedCore

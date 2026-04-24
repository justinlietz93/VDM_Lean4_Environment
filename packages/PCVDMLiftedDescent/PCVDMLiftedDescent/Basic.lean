/-
  PCVDMLiftedDescent.Basic

  Theorem surface for the lifted-descent solver (pc_vdm_lifted_descent_solver).

  Ships as a *standalone* package: re-states the PC primitives locally to keep
  CI fast and independent of Mathlib. A follow-up revision can swap these for
  imports from `PCVDMLiftedCore` once the repo-wide dependency graph is wired.

  All proofs here are either `rfl` or boolean case-splits, so the whole file
  type-checks in under a second.
-/

namespace PCVDMLiftedDescent

/-! ## Lifted coordinates -/

structure PhaseState where
  A : Nat
  u : Nat
  v : Nat
  t : Nat
  deriving Repr, DecidableEq

def Q (x : PhaseState) : PhaseState := { x with t := x.t + 1 }
def B (x : PhaseState) : PhaseState := { x with u := x.v, v := x.u + x.v }
def L (x : PhaseState) : PhaseState := { x with A := x.A + 1, t := x.t + 1 }

def R (x : PhaseState) : PhaseState := Q (B x)
def S (x : PhaseState) : PhaseState := Q x
def T (x : PhaseState) : PhaseState :=
  { A := x.A + 1, u := 1, v := x.A + 1, t := x.t + 1 }

def PiRed (x : PhaseState) : Nat × Nat := (x.u, x.v)
def GRed  (q : Nat × Nat)  : Nat × Nat := (q.2, q.1 + q.2)

theorem red_quotient_B (x : PhaseState) :
    PiRed (B x) = GRed (PiRed x) := rfl

theorem macro_R_factors (x : PhaseState) : R x = Q (B x) := rfl

/-! ## Termination gate discipline -/

/-- The three witnesses required for the solver to open the final projection. -/
structure TerminationReport where
  lowFieldVariance : Bool
  zeroWalkers : Bool
  stationaryEnergy : Bool
  deriving Repr, DecidableEq

def SelfTerminated (r : TerminationReport) : Bool :=
  r.lowFieldVariance && r.zeroWalkers && r.stationaryEnergy

theorem self_termination_requires_zero_walkers
    (r : TerminationReport) (h : SelfTerminated r = true) :
    r.zeroWalkers = true := by
  unfold SelfTerminated at h
  cases r.lowFieldVariance <;> cases r.zeroWalkers <;> cases r.stationaryEnergy
    <;> simp at h ⊢

theorem self_termination_requires_stationary_energy
    (r : TerminationReport) (h : SelfTerminated r = true) :
    r.stationaryEnergy = true := by
  unfold SelfTerminated at h
  cases r.lowFieldVariance <;> cases r.zeroWalkers <;> cases r.stationaryEnergy
    <;> simp at h ⊢

theorem self_termination_requires_low_field_variance
    (r : TerminationReport) (h : SelfTerminated r = true) :
    r.lowFieldVariance = true := by
  unfold SelfTerminated at h
  cases r.lowFieldVariance <;> cases r.zeroWalkers <;> cases r.stationaryEnergy
    <;> simp at h ⊢

/-! ## Projection-open gate

  The solver must never open the visible projection more than once per solve,
  and must never open it without a self-termination witness. We encode this
  as a trivial state machine whose invariant is preserved by construction. -/

structure SolverGate where
  projectionOpenedCount : Nat
  terminatedWitness     : Bool
  deriving Repr, DecidableEq

/-- Initial gate state: nothing opened, not terminated. -/
def initGate : SolverGate :=
  { projectionOpenedCount := 0, terminatedWitness := false }

/-- Mark termination witness; cannot change projection count. -/
def setTerminated (g : SolverGate) (r : TerminationReport) : SolverGate :=
  { g with terminatedWitness := SelfTerminated r }

/-- Attempt to open the projection. Only fires when witness is true and
    count is currently zero; otherwise the gate is unchanged. -/
def openProjection (g : SolverGate) : SolverGate :=
  if g.terminatedWitness && g.projectionOpenedCount = 0 then
    { g with projectionOpenedCount := 1 }
  else
    g

/-- **Gate discipline theorem:** the projection count after a legal open is
    at most 1. This is the Lean-level analogue of the Python invariant
    `raise RuntimeError("final projection has already been opened")`. -/
theorem projection_count_bounded (g : SolverGate)
    (h : g.projectionOpenedCount ≤ 1) :
    (openProjection g).projectionOpenedCount ≤ 1 := by
  unfold openProjection
  split
  · -- branch taken: new count is literally 1, so 1 ≤ 1.
    simp
  · -- branch not taken: gate unchanged, hypothesis applies.
    exact h

/-- Opening without a termination witness is a no-op. -/
theorem open_without_witness_is_noop (g : SolverGate)
    (h : g.terminatedWitness = false) :
    openProjection g = g := by
  unfold openProjection
  simp [h]

end PCVDMLiftedDescent

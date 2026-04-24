namespace PCVDMLiftedDescent

structure PhaseState where
  A : Nat
  u : Nat
  v : Nat
  t : Nat
  deriving Repr, DecidableEq

def Q (x : PhaseState) : PhaseState :=
  { x with t := x.t + 1 }

def B (x : PhaseState) : PhaseState :=
  { x with u := x.v, v := x.u + x.v }

def L (x : PhaseState) : PhaseState :=
  { x with A := x.A + 1, t := x.t + 1 }

def R (x : PhaseState) : PhaseState :=
  Q (B x)

def S (x : PhaseState) : PhaseState :=
  Q x

def T (x : PhaseState) : PhaseState :=
  { A := x.A + 1, u := 1, v := x.A + 1, t := x.t + 1 }

def PiRed (x : PhaseState) : Nat × Nat :=
  (x.u, x.v)

def GRed (q : Nat × Nat) : Nat × Nat :=
  (q.2, q.1 + q.2)

theorem Q_adds_one_tick (x : PhaseState) : (Q x).t = x.t + 1 := rfl

theorem B_preserves_tick (x : PhaseState) : (B x).t = x.t := rfl

theorem L_adds_one_tick (x : PhaseState) : (L x).t = x.t + 1 := rfl

theorem red_quotient_B (x : PhaseState) : PiRed (B x) = GRed (PiRed x) := rfl

theorem macro_R_is_Q_after_B (x : PhaseState) : R x = Q (B x) := rfl

theorem macro_S_is_Q (x : PhaseState) : S x = Q x := rfl

theorem macro_T_lifts_host (x : PhaseState) : (T x).A = x.A + 1 := rfl

structure TerminationReport where
  lowFieldVariance : Bool
  zeroWalkers : Bool
  stationaryEnergy : Bool
  deriving Repr, DecidableEq

def SelfTerminated (r : TerminationReport) : Bool :=
  r.lowFieldVariance && r.zeroWalkers && r.stationaryEnergy

theorem self_termination_requires_zero_walkers
    (r : TerminationReport)
    (h : SelfTerminated r = true) : r.zeroWalkers = true := by
  unfold SelfTerminated at h
  simp at h
  exact h.1.2

theorem self_termination_requires_stationary_energy
    (r : TerminationReport)
    (h : SelfTerminated r = true) : r.stationaryEnergy = true := by
  unfold SelfTerminated at h
  simp at h
  exact h.2

end PCVDMLiftedDescent

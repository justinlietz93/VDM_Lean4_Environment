import Std

namespace PCVDMLiftedCore

structure BPair where
  u : Nat
  v : Nat
  deriving DecidableEq, Repr

def sortPair (a b : Nat) : BPair :=
  if a <= b then { u := a, v := b } else { u := b, v := a }

def refine (p : BPair) : BPair :=
  sortPair p.v (p.u + p.v)

def iterate {α : Type} (n : Nat) (f : α → α) (x : α) : α :=
  match n with
  | 0 => x
  | Nat.succ k => iterate k f (f x)

def b9 : BPair := iterate 9 refine { u := 1, v := 1 }

theorem B9_anchor_55_89 : b9 = { u := 55, v := 89 } := by
  native_decide

theorem B9_product_4895 : b9.u * b9.v = 4895 := by
  native_decide

structure Phase where
  A : Nat
  u : Nat
  v : Nat
  tick : Nat
  kappa : Nat
  deriving DecidableEq, Repr

def visiblePhase (p : Phase) : Nat := p.tick % 4

def recomputeKappa (tick : Nat) : Nat := tick / 4

def Q (p : Phase) : Phase :=
  { p with tick := p.tick + 1, kappa := recomputeKappa (p.tick + 1) }

def B (p : Phase) : Phase :=
  let q := refine { u := p.u, v := p.v }
  { p with u := q.u, v := q.v }

def L (p : Phase) : Phase :=
  let nextA := p.A + 1
  { A := nextA, u := 1, v := Nat.max 1 nextA, tick := p.tick + 1,
    kappa := recomputeKappa (p.tick + 1) }

def Q4 (p : Phase) : Phase := Q (Q (Q (Q p)))

def p0 : Phase := { A := 0, u := 1, v := 1, tick := 0, kappa := 0 }
def p1 : Phase := { A := 0, u := 1, v := 1, tick := 4, kappa := 1 }

theorem visible_not_state_complete : p0 ≠ p1 ∧ visiblePhase p0 = visiblePhase p1 := by
  native_decide

theorem Q4_preserves_visible_sample : visiblePhase (Q4 p0) = visiblePhase p0 := by
  native_decide

theorem Q4_increments_kappa_sample : (Q4 p0).kappa = p0.kappa + 1 := by
  native_decide

inductive Macro where
  | R | S | T
  deriving DecidableEq, Repr

def selector (width floorDen : Nat) (p : Phase) : Macro :=
  if p.tick % width = width - 1 then Macro.T
  else if p.u * p.v < floorDen then Macro.R
  else Macro.S

theorem selector_refines_initial : selector 64 4096 p0 = Macro.R := by
  native_decide

def anchorPhase : Phase := { A := 0, u := 55, v := 89, tick := 10, kappa := 2 }

theorem selector_holds_anchor : selector 64 4096 anchorPhase = Macro.S := by
  native_decide

def carryPhase : Phase := { A := 0, u := 1, v := 1, tick := 63, kappa := 15 }

theorem selector_lifts_on_carry : selector 64 4096 carryPhase = Macro.T := by
  native_decide

end PCVDMLiftedCore

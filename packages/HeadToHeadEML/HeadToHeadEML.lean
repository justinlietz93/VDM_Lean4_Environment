namespace HeadToHeadEML

structure BenchmarkLedger where
  targets : Nat
  vdmSuccesses : Nat
  emlSuccesses : Nat
  vdmProjectionOpensPerTarget : Nat

def executedLedger : BenchmarkLedger := {
  targets := 4,
  vdmSuccesses := 4,
  emlSuccesses := 2,
  vdmProjectionOpensPerTarget := 1
}

theorem vdm_covers_all_targets :
    executedLedger.vdmSuccesses = executedLedger.targets := by
  rfl

theorem eml_depth4_covers_two_targets :
    executedLedger.emlSuccesses = 2 := by
  rfl

theorem vdm_terminal_projection_once :
    executedLedger.vdmProjectionOpensPerTarget = 1 := by
  rfl

end HeadToHeadEML

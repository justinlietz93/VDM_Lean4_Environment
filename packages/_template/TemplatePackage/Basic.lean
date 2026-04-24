/-
  TemplatePackage.Basic

  Starting skeleton for a new VDM/PC theorem surface. Copy the enclosing
  folder with `scripts/new_package.sh <Name>`, which renames the folder,
  the module, and the namespace. Replace the body with your theorems.

  Keep proofs on this template-lite style (rfl / decide / finite case-splits)
  whenever possible. If you need Mathlib, add it as a require in `lakefile.toml`
  and accept the 30+ minute cold build on CI.
-/

namespace TemplatePackage

/-- Replace me with a real structure. -/
structure Placeholder where
  value : Nat
  deriving Repr, DecidableEq

/-- Sanity theorem to confirm the package type-checks end-to-end. -/
theorem placeholder_refl (p : Placeholder) : p = p := rfl

end TemplatePackage

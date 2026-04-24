# PCVDMLiftedCore Lean surface

This Lean 4 package attacks the theorem-shape surface used by the Python artifact:

- balanced refinement reaches `(55,89)` at depth 9;
- the anchor product is `4895`;
- visible phase is not state-complete;
- `Q^4` preserves visible phase and increments completed-turn memory on the finite witness;
- selector cases produce `R`, `S`, and `T` on the executable witness states.

Run:

```bash
lake build
```

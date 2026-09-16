import Mathlib.Data.Nat.Basic
import Mathlib.Analysis.SpecialFunctions.Complex.Circle
import Mathlib.Topology.Homotopy.Lifting
import Mathlib.AlgebraicTopology.FundamentalGroupoid.SimplyConnected
import Mathlib.Analysis.Convex.Contractible

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Disposable exact-pin probe for one explicit Poincaré endgame topology gap.
The proof is adapted from the Mathlib-only module
`zblore/csd-lean4/CircleFundamentalGroup.lean`, which uses exactly the same
Lean 4.33.0 / Mathlib commit as this verifier.
-/

open Real

namespace ClayPoincareCircle

/-- The basepoint `0 : ℝ` lies in the fibre of `Circle.exp` over `1`. -/
def expFibreZero : (Circle.exp ⁻¹' {1} : Set ℝ) := ⟨0, by simp⟩

/-- The pinned Mathlib quotient-covering API identifies the circle fundamental
group with the deck group `2πℤ`, written multiplicatively. -/
noncomputable def fundamentalGroupEquivZMultiples :
    FundamentalGroup Circle 1 ≃* (Multiplicative (AddSubgroup.zmultiples (2 * π)))ᵐᵒᵖ :=
  Circle.isAddQuotientCoveringMap_exp.fundamentalGroupEquiv expFibreZero

/-- The deck group `2πℤ` is nontrivial. -/
theorem nontrivial_zmultiples_two_pi : Nontrivial (AddSubgroup.zmultiples (2 * π)) := by
  refine ⟨⟨0, ⟨2 * π, AddSubgroup.mem_zmultiples _⟩, ?_⟩⟩
  simp [Subtype.ext_iff, Real.pi_ne_zero]

/-- The standard circle has nontrivial fundamental group. -/
theorem fundamentalGroup_nontrivial : Nontrivial (FundamentalGroup Circle 1) := by
  have : Nontrivial (AddSubgroup.zmultiples (2 * π)) := nontrivial_zmultiples_two_pi
  exact fundamentalGroupEquivZMultiples.symm.injective.nontrivial

/-- The standard circle is not simply connected. -/
theorem circle_not_simplyConnectedSpace : ¬ SimplyConnectedSpace Circle := by
  intro h
  have hsub : Subsingleton (FundamentalGroup Circle 1) := inferInstance
  exact (not_subsingleton_iff_nontrivial.mpr fundamentalGroup_nontrivial) hsub

end ClayPoincareCircle

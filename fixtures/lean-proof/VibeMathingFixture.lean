import Mathlib.Data.Nat.Basic
import Mathlib.Topology.Covering.AddCircle
import Mathlib.Topology.Instances.AddCircle.Real
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
This second probe uses the additive circle `ℝ/ℤ` directly, avoiding the heavier
complex-circle import while retaining Mathlib's quotient-covering computation.
-/

namespace ClayPoincareCircle

abbrev Circle1 := AddCircle (1 : ℝ)

/-- The basepoint `0 : ℝ` lies over `0 : ℝ/ℤ`. -/
def addCircleFibreZero : (((↑) : ℝ → Circle1) ⁻¹' {0} : Set ℝ) := ⟨0, by simp⟩

/-- The pinned Mathlib quotient-covering API identifies the fundamental group of
`ℝ/ℤ` with the opposite of the period subgroup `ℤ`, written multiplicatively. -/
noncomputable def fundamentalGroupEquivZMultiples :
    FundamentalGroup Circle1 0 ≃*
      (Multiplicative (AddSubgroup.zmultiples (1 : ℝ)))ᵐᵒᵖ :=
  (AddCircle.isAddQuotientCoveringMap_coe (1 : ℝ)).fundamentalGroupEquiv addCircleFibreZero

/-- The period subgroup `ℤ ⊂ ℝ` is nontrivial. -/
theorem nontrivial_zmultiples_one : Nontrivial (AddSubgroup.zmultiples (1 : ℝ)) := by
  refine ⟨⟨0, ⟨1, AddSubgroup.mem_zmultiples _⟩, ?_⟩⟩
  simp [Subtype.ext_iff]

/-- The additive unit circle has nontrivial fundamental group. -/
theorem fundamentalGroup_nontrivial : Nontrivial (FundamentalGroup Circle1 0) := by
  have : Nontrivial (AddSubgroup.zmultiples (1 : ℝ)) := nontrivial_zmultiples_one
  exact fundamentalGroupEquivZMultiples.symm.injective.nontrivial

/-- The additive unit circle is not simply connected. -/
theorem addCircle_not_simplyConnectedSpace : ¬ SimplyConnectedSpace Circle1 := by
  intro h
  have hsub : Subsingleton (FundamentalGroup Circle1 0) := inferInstance
  exact (not_subsingleton_iff_nontrivial.mpr fundamentalGroup_nontrivial) hsub

end ClayPoincareCircle

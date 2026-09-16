import Mathlib.Data.Nat.Basic
import Mathlib.Geometry.Manifold.ChartedSpace

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Temporary elaboration-only diagnostic for `problem:clay-poincare`.
This commit isolates the charted-space import without `PiL2`, using `ℝ` as a
lightweight model to test the compact-to-second-countable interface.
It is not a proof of the Poincaré conjecture and must not be merged.
-/

namespace ClayPoincare

theorem secondCountable_of_compact_charted_real
    (M : Type*) [TopologicalSpace M] [ChartedSpace ℝ M] [CompactSpace M] :
    SecondCountableTopology M := by
  exact ChartedSpace.secondCountable_of_sigmaCompact ℝ M

end ClayPoincare

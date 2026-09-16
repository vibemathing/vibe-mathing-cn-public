import Mathlib.Data.Nat.Basic
import Mathlib.AlgebraicTopology.FundamentalGroupoid.SimplyConnected
import Mathlib.Geometry.Manifold.ChartedSpace

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Temporary diagnostic for `problem:clay-poincare`.
This isolates the lightweight R^3 model `Fin 3 → ℝ` together with the exact
manifold assumptions, without the sphere or target conclusion.
-/

namespace ClayPoincare

abbrev Euclidean3 := Fin 3 → ℝ

theorem euclidean3_nonempty : Nonempty Euclidean3 := by
  exact ⟨0⟩

theorem assumptions_elaborate
    (M : Type*) [TopologicalSpace M] [T2Space M]
    [ChartedSpace Euclidean3 M] [SimplyConnectedSpace M] [CompactSpace M] : True := by
  trivial

end ClayPoincare

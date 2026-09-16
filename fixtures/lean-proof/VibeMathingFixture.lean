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
This isolates the standard 3-sphere subtype encoding on `Fin 4 → ℝ`.
-/

namespace ClayPoincare

abbrev Euclidean3 := Fin 3 → ℝ

def Sphere3 :=
  {x : Fin 4 → ℝ //
    x 0 * x 0 + x 1 * x 1 + x 2 * x 2 + x 3 * x 3 = 1}

end ClayPoincare

import Mathlib.Data.Nat.Basic
import Mathlib.Geometry.Manifold.ChartedSpace
import Mathlib.Topology.Homeomorph.Defs

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Temporary target-type diagnostic for `problem:clay-poincare`.
This probe checks that the algebraic standard 3-sphere subtype exposes its
induced topology when kept definitionally transparent with `abbrev`.
-/

namespace ClayPoincare

abbrev Sphere3 :=
  {x : Fin 4 → ℝ //
    x 0 * x 0 + x 1 * x 1 + x 2 * x 2 + x 3 * x 3 = 1}

def sphere3TopologicalSpace : TopologicalSpace Sphere3 := inferInstance

end ClayPoincare

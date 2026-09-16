import Mathlib.Data.Nat.Basic
import Mathlib.AlgebraicTopology.FundamentalGroupoid.SimplyConnected
import Mathlib.Geometry.Manifold.ChartedSpace

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Temporary target-type diagnostic for `problem:clay-poincare`.
This keeps the full topological input assumptions and homeomorphism conclusion,
using lightweight finite-product coordinate models to avoid the `PiL2` resource
failure. It does not prove the target proposition.
-/

namespace ClayPoincare

abbrev Euclidean3 := Fin 3 → ℝ

def Sphere3 :=
  {x : Fin 4 → ℝ //
    x 0 * x 0 + x 1 * x 1 + x 2 * x 2 + x 3 * x 3 = 1}

def Target (M : Type*) [TopologicalSpace M] [T2Space M]
    [ChartedSpace Euclidean3 M] [SimplyConnectedSpace M] [CompactSpace M] : Prop :=
  Nonempty (M ≃ₜ Sphere3)

theorem target_iff_explicit
    (M : Type*) [TopologicalSpace M] [T2Space M]
    [ChartedSpace Euclidean3 M] [SimplyConnectedSpace M] [CompactSpace M] :
    Target M ↔ Nonempty (M ≃ₜ Sphere3) :=
  Iff.rfl

end ClayPoincare

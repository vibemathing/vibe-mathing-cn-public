import Mathlib.Data.Nat.Basic
import Mathlib.AlgebraicTopology.FundamentalGroupoid.SimplyConnected
import Mathlib.Geometry.Manifold.ChartedSpace

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Temporary elaboration-only diagnostic for `problem:clay-poincare`.
This probe encodes the exact topological target without importing `PiL2`:
`Fin 3 → ℝ` is the standard product model of R^3, and `Sphere3` is the
unit sphere in R^4 defined by the sum-of-squares equation.
It is not a proof of the Poincaré conjecture and must not be merged.
-/

namespace ClayPoincare

abbrev Euclidean3 := Fin 3 → ℝ

def Sphere3 :=
  {x : Fin 4 → ℝ //
    x 0 * x 0 + x 1 * x 1 + x 2 * x 2 + x 3 * x 3 = 1}

def Target (M : Type*) [TopologicalSpace M] [T2Space M]
    [ChartedSpace Euclidean3 M] [SimplyConnectedSpace M] [CompactSpace M] : Prop :=
  Nonempty (M ≃ₜ Sphere3)

theorem secondCountable_of_compact_charted
    (M : Type*) [TopologicalSpace M] [ChartedSpace Euclidean3 M] [CompactSpace M] :
    SecondCountableTopology M := by
  exact ChartedSpace.secondCountable_of_sigmaCompact Euclidean3 M

theorem target_iff_explicit
    (M : Type*) [TopologicalSpace M] [T2Space M]
    [ChartedSpace Euclidean3 M] [SimplyConnectedSpace M] [CompactSpace M] :
    Target M ↔ Nonempty (M ≃ₜ Sphere3) :=
  Iff.rfl

end ClayPoincare

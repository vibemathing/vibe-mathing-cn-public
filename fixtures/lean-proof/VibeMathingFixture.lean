import Mathlib.Data.Nat.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Temporary elaboration-only diagnostic for `problem:clay-poincare`.
This commit isolates the exact Euclidean-space import used by the target.
It is not a proof of the Poincaré conjecture and must not be merged.
-/

namespace ClayPoincare

abbrev Euclidean3 := EuclideanSpace ℝ (Fin 3)

theorem euclidean3_nonempty : Nonempty Euclidean3 := by
  exact ⟨0⟩

end ClayPoincare

import Mathlib.Data.Nat.Basic
import Mathlib.Analysis.Complex.Circle
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.LinearAlgebra.Complex.FiniteDimensional

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Disposable exact-pin probe for the geometric circle model used by OpenGA's
Poincare extinction endgame.  This file proves only the homeomorphism between
OpenGA's `SphereOne` model and Mathlib's complex unit circle.
-/

open Metric Complex

namespace ClayPoincareSphereOne

noncomputable section

/-- OpenGA's standard geometric one-sphere model. -/
abbrev SphereOne := ↥(Metric.sphere (0 : EuclideanSpace ℝ (Fin 2)) 1)

/-- Standard real-linear isometry between `ℂ` and two-dimensional Euclidean space. -/
def complexToEuclideanLinearIsometryEquiv : ℂ ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin 2) := by
  let b : OrthonormalBasis (Fin (Module.finrank ℝ ℂ)) ℝ ℂ := stdOrthonormalBasis ℝ ℂ
  let e : Fin (Module.finrank ℝ ℂ) ≃ Fin 2 := finCongr finrank_real_complex
  let b' : OrthonormalBasis (Fin 2) ℝ ℂ := b.reindex e
  exact b'.repr

/-- The Euclidean unit one-sphere is homeomorphic to Mathlib's complex unit circle. -/
def sphereOneCircleHomeomorph : SphereOne ≃ₜ Circle := by
  let e : EuclideanSpace ℝ (Fin 2) ≃ₗᵢ[ℝ] ℂ := complexToEuclideanLinearIsometryEquiv.symm
  have h_norm : ∀ x : EuclideanSpace ℝ (Fin 2), ‖e x‖ = ‖x‖ := by
    intro x
    exact e.norm_map x
  have h1 : ∀ x : EuclideanSpace ℝ (Fin 2), ‖x‖ = 1 → ‖e x‖ = 1 := by
    intro x hx
    rw [h_norm x, hx]
  have h2 : ∀ y : ℂ, ‖y‖ = 1 → ‖e.symm y‖ = 1 := by
    intro y hy
    have h : ‖e.symm y‖ = ‖y‖ := e.symm.norm_map y
    rw [h, hy]
  refine
    { toFun := fun x : SphereOne =>
        (⟨e x, by
          have hx : ‖(x : EuclideanSpace ℝ (Fin 2))‖ = 1 :=
            mem_sphere_zero_iff_norm.mp x.property
          exact mem_sphere_zero_iff_norm.mpr (h1 x.val hx)⟩ : Circle)
      invFun := fun y : Circle =>
        (⟨e.symm y, by
          have hy : ‖(y : ℂ)‖ = 1 := mem_sphere_zero_iff_norm.mp y.property
          exact mem_sphere_zero_iff_norm.mpr (h2 y.val hy)⟩ : SphereOne)
      left_inv := by
        intro x
        apply Subtype.ext
        simp
      right_inv := by
        intro y
        apply Subtype.ext
        simp
      continuous_toFun := by fun_prop
      continuous_invFun := by fun_prop }

end

end ClayPoincareSphereOne

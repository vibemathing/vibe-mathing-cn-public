import Mathlib.Data.Nat.Basic
import Mathlib.Analysis.SpecialFunctions.Complex.Circle
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.LinearAlgebra.Complex.FiniteDimensional
import Mathlib.Topology.Covering.AddCircle
import Mathlib.Topology.Instances.AddCircle.Real
import Mathlib.Topology.Homotopy.Lifting
import Mathlib.AlgebraicTopology.FundamentalGroupoid.SimplyConnected
import Mathlib.Analysis.Convex.Contractible
import Mathlib.Topology.Homotopy.Product

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Disposable exact-pin replay of the complete standard sphere-handle obstruction
needed by the three-dimensional Poincare extinction endgame.
-/

open Metric Complex

namespace ClayPoincareSphereHandle

noncomputable section

abbrev SphereOne := ↥(Metric.sphere (0 : EuclideanSpace ℝ (Fin 2)) 1)
abbrev SphereTwo := ↥(Metric.sphere (0 : EuclideanSpace ℝ (Fin 3)) 1)
abbrev Circle1 := AddCircle (1 : ℝ)

def complexToEuclideanLinearIsometryEquiv : ℂ ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin 2) := by
  let b : OrthonormalBasis (Fin (Module.finrank ℝ ℂ)) ℝ ℂ := stdOrthonormalBasis ℝ ℂ
  let e : Fin (Module.finrank ℝ ℂ) ≃ Fin 2 := finCongr finrank_real_complex
  let b' : OrthonormalBasis (Fin 2) ℝ ℂ := b.reindex e
  exact b'.repr

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

def sphereOneAddCircleHomeomorph : SphereOne ≃ₜ Circle1 :=
  sphereOneCircleHomeomorph.trans
    (AddCircle.homeomorphCircle (by norm_num : (1 : ℝ) ≠ 0)).symm

noncomputable def sphereTwoBasepoint : SphereTwo := by
  have h : (Metric.sphere (0 : EuclideanSpace ℝ (Fin 3)) 1).Nonempty :=
    NormedSpace.sphere_nonempty.mpr zero_le_one
  exact ⟨h.some, h.some_mem⟩

def addCircleFibreZero : (((↑) : ℝ → Circle1) ⁻¹' {0} : Set ℝ) := ⟨0, by simp⟩

noncomputable def circleFundamentalGroupEquivZ :
    FundamentalGroup Circle1 0 ≃*
      (Multiplicative (AddSubgroup.zmultiples (1 : ℝ)))ᵐᵒᵖ :=
  (AddCircle.isAddQuotientCoveringMap_coe (1 : ℝ)).fundamentalGroupEquiv addCircleFibreZero

theorem nontrivial_zmultiples_one : Nontrivial (AddSubgroup.zmultiples (1 : ℝ)) := by
  refine ⟨⟨0, ⟨1, AddSubgroup.mem_zmultiples _⟩, ?_⟩⟩
  simp [Subtype.ext_iff]

theorem circleFundamentalGroup_nontrivial : Nontrivial (FundamentalGroup Circle1 0) := by
  have : Nontrivial (AddSubgroup.zmultiples (1 : ℝ)) := nontrivial_zmultiples_one
  exact circleFundamentalGroupEquivZ.symm.injective.nontrivial

open Path.Homotopic

variable {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]

def FundamentalGroup.prodMulEquiv (x : X) (y : Y) :
    FundamentalGroup (X × Y) (x, y) ≃*
      FundamentalGroup X x × FundamentalGroup Y y where
  toFun γ :=
    (FundamentalGroup.map (ContinuousMap.fst : C(X × Y, X)) (x, y) γ,
      FundamentalGroup.map (ContinuousMap.snd : C(X × Y, Y)) (x, y) γ)
  invFun γ := prod γ.1 γ.2
  left_inv γ := prod_projLeft_projRight γ
  right_inv γ := Prod.ext (projLeft_prod γ.1 γ.2) (projRight_prod γ.1 γ.2)
  map_mul' γ δ :=
    Prod.ext ((FundamentalGroup.map (ContinuousMap.fst : C(X × Y, X)) (x, y)).map_mul γ δ)
      ((FundamentalGroup.map (ContinuousMap.snd : C(X × Y, Y)) (x, y)).map_mul γ δ)

theorem prod_not_simplyConnectedSpace_of_nontrivial_fundamentalGroup
    (x : X) (y : Y) [Nontrivial (FundamentalGroup X x)] :
    ¬ SimplyConnectedSpace (X × Y) := by
  intro h
  have hsub : Subsingleton (FundamentalGroup (X × Y) (x, y)) := inferInstance
  have hsource : Nontrivial (FundamentalGroup (X × Y) (x, y)) :=
    (FundamentalGroup.prodMulEquiv x y).symm.injective.nontrivial
  exact (not_subsingleton_iff_nontrivial.mpr hsource) hsub

theorem addCircle_prod_not_simplyConnectedSpace (y : Y) :
    ¬ SimplyConnectedSpace (Circle1 × Y) := by
  letI : Nontrivial (FundamentalGroup Circle1 0) := circleFundamentalGroup_nontrivial
  exact prod_not_simplyConnectedSpace_of_nontrivial_fundamentalGroup (X := Circle1) 0 y

theorem sphereOneSphereTwo_not_simplyConnectedSpace :
    ¬ SimplyConnectedSpace (SphereOne × SphereTwo) := by
  intro h
  let eProd : (SphereOne × SphereTwo) ≃ₜ (Circle1 × SphereTwo) :=
    sphereOneAddCircleHomeomorph.prodCongr (Homeomorph.refl SphereTwo)
  have h' : SimplyConnectedSpace (Circle1 × SphereTwo) :=
    eProd.toHomotopyEquiv.simplyConnectedSpace_iff.mp h
  exact addCircle_prod_not_simplyConnectedSpace sphereTwoBasepoint h'

theorem not_simply_connected_sphere_handle_model
    {M : Type*} [TopologicalSpace M]
    (hhandle : Nonempty (M ≃ₜ (SphereOne × SphereTwo))) :
    ¬ SimplyConnectedSpace M := by
  intro hM
  let eM := hhandle.some
  have hprod : SimplyConnectedSpace (SphereOne × SphereTwo) :=
    eM.toHomotopyEquiv.simplyConnectedSpace_iff.mp hM
  exact sphereOneSphereTwo_not_simplyConnectedSpace hprod

end

end ClayPoincareSphereHandle

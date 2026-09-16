import Mathlib.Data.Nat.Basic
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
Disposable exact-pin composition probe for the `S¹ × S²` obstruction used by
OpenGA's Poincaré connected-sum endgame. It combines the independently passing
AddCircle fundamental-group computation and product fundamental-group equivalence.
-/

namespace ClayPoincareCircleProduct

open Path.Homotopic

noncomputable section

abbrev Circle1 := AddCircle (1 : ℝ)

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
  have hprod : Nontrivial (FundamentalGroup X x × FundamentalGroup Y y) := by
    infer_instance
  have hsource : Nontrivial (FundamentalGroup (X × Y) (x, y)) :=
    (FundamentalGroup.prodMulEquiv x y).symm.injective.nontrivial
  exact (not_subsingleton_iff_nontrivial.mpr hsource) hsub

theorem addCircle_prod_not_simplyConnectedSpace
    {Y : Type*} [TopologicalSpace Y] (y : Y) :
    ¬ SimplyConnectedSpace (Circle1 × Y) := by
  letI : Nontrivial (FundamentalGroup Circle1 0) := circleFundamentalGroup_nontrivial
  exact prod_not_simplyConnectedSpace_of_nontrivial_fundamentalGroup (X := Circle1) 0 y

/-- Transport form of the sphere-handle obstruction.  Once a geometric circle
model `A` is homeomorphic to `AddCircle 1`, any space homeomorphic to `A × Y`
is not simply connected.  The geometric `SphereOne ≃ₜ AddCircle 1` bridge is
kept as an explicit input so its heavier Euclidean import can be audited
separately. -/
theorem handle_not_simplyConnectedSpace_of_circle_homeomorph
    {M A Y : Type*} [TopologicalSpace M] [TopologicalSpace A] [TopologicalSpace Y]
    (eA : A ≃ₜ Circle1) (eM : M ≃ₜ (A × Y)) (y : Y) :
    ¬ SimplyConnectedSpace M := by
  intro hM
  have hAY : SimplyConnectedSpace (A × Y) :=
    eM.toHomotopyEquiv.simplyConnectedSpace_iff.mp hM
  let eProd : (A × Y) ≃ₜ (Circle1 × Y) := eA.prodCongr (Homeomorph.refl Y)
  have hCY : SimplyConnectedSpace (Circle1 × Y) :=
    eProd.toHomotopyEquiv.simplyConnectedSpace_iff.mp hAY
  exact addCircle_prod_not_simplyConnectedSpace y hCY

end

end ClayPoincareCircleProduct

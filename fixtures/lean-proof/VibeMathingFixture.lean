import Mathlib.Data.Nat.Basic
import Mathlib.AlgebraicTopology.FundamentalGroupoid.FundamentalGroup
import Mathlib.Topology.Homotopy.Product

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Disposable exact-pin probe for the product fundamental-group lemma needed by the
Poincaré connected-sum endgame. The construction is adapted from TauCeti's
Apache-2.0 `FundamentalGroup.prodMulEquiv`, using only Mathlib APIs.
-/

namespace ClayPoincareProduct

open Path.Homotopic

noncomputable section

variable {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]

/-- The fundamental group of a binary product is the product of the two
fundamental groups. -/
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

end

end ClayPoincareProduct

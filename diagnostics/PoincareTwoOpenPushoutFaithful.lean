import PoincareTwoOpenPushoutCocone

open CategoryTheory CategoryTheory.Limits
open TopologicalSpace

universe u

variable {X : Type u} [TopologicalSpace X]

/-- For a simply connected overlap, the left leg of the strict two-open
pushout test cocone is faithful. -/
theorem twoOpenPushoutTestCocone_inl_faithful
    (U V : Opens X)
    [SimplyConnectedSpace (U ⊓ V)]
    [PathConnectedSpace U] [PathConnectedSpace V]
    (w₀ : U ⊓ V) :
    (twoOpenPushoutTestCocone U V w₀).inl.Faithful := by
  dsimp [twoOpenPushoutTestCocone]
  apply basedTransportToConstantHom_faithful
  apply pushoutI_of_injective_of_subsingleton

/-- For a simply connected overlap, the right leg of the strict two-open
pushout test cocone is faithful. -/
theorem twoOpenPushoutTestCocone_inr_faithful
    (U V : Opens X)
    [SimplyConnectedSpace (U ⊓ V)]
    [PathConnectedSpace U] [PathConnectedSpace V]
    (w₀ : U ⊓ V) :
    (twoOpenPushoutTestCocone U V w₀).inr.Faithful := by
  dsimp [twoOpenPushoutTestCocone]
  apply basedTransportToConstantHom_faithful
  apply pushoutI_of_injective_of_subsingleton

#print axioms twoOpenPushoutTestCocone_inl_faithful
#print axioms twoOpenPushoutTestCocone_inr_faithful

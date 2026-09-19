import Mathlib.GroupTheory.PushoutI
import Mathlib.AlgebraicTopology.FundamentalGroupoid.SimplyConnected
import Mathlib.CategoryTheory.Limits.Shapes.Pullback.PullbackCone

open CategoryTheory CategoryTheory.Limits

universe u v

/-- A path-connected groupoid can be transported to the one-object groupoid at
a chosen base object by conjugating with chosen connecting arrows. -/
noncomputable def basedTransportFunctor {C : Type u} [Groupoid.{v} C]
    (c : C) (p : ∀ x : C, c ⟶ x) :
    C ⥤ SingleObj (End c) where
  obj _ := SingleObj.star _
  map {x y} f := (show End c from p x ≫ f ≫ inv (p y))
  map_id x := by
    dsimp
    rw [Category.comp_id, IsIso.hom_inv_id, ← End.one_def, SingleObj.id_as_one]
  map_comp f g := by
    rw [SingleObj.comp_as_mul, End.mul_def]
    simp only [Category.assoc, IsIso.inv_hom_id_assoc]

/-- Conjugation by chosen connecting arrows is injective on every hom-set. -/
theorem basedTransportFunctor_map_injective
    {C : Type u} [Groupoid.{v} C]
    (c : C) (p : ∀ x : C, c ⟶ x) {x y : C} :
    Function.Injective (fun f : x ⟶ y => (basedTransportFunctor c p).map f) := by
  intro f g h
  change p x ≫ f ≫ inv (p y) = p x ≫ g ≫ inv (p y) at h
  simp only [← Category.assoc] at h
  exact (cancel_epi (p x)).1 ((cancel_mono (inv (p y))).1 h)

instance basedTransportFunctor_faithful
    {C : Type u} [Groupoid.{v} C]
    (c : C) (p : ∀ x : C, c ⟶ x) :
    (basedTransportFunctor c p).Faithful where
  map_injective := by
    intro x y f g h
    exact basedTransportFunctor_map_injective c p h

universe w

variable {ι : Type*} {H : Type*} {G : ι → Type*}
variable [Group H] [∀ i, Group (G i)]

/-- If the amalgamating group is subsingleton, every canonical factor map into
the group pushout is injective. -/
theorem pushoutI_of_injective_of_subsingleton
    (φ : ∀ i, H →* G i) [Subsingleton H] (i : ι) :
    Function.Injective (Monoid.PushoutI.of (φ := φ) i) := by
  apply Monoid.PushoutI.of_injective
  intro j x y h
  exact Subsingleton.elim x y

/-- Consequently, if the pushout itself is subsingleton, every factor group is
subsingleton. -/
theorem subsingleton_factor_of_pushoutI
    (φ : ∀ i, H →* G i) [Subsingleton H]
    [Subsingleton (Monoid.PushoutI φ)] (i : ι) :
    Subsingleton (G i) := by
  constructor
  intro x y
  apply pushoutI_of_injective_of_subsingleton φ i
  exact Subsingleton.elim _ _

/-- An injective monoid homomorphism induces a faithful functor between
the corresponding one-object categories. -/
theorem monoidHom_toFunctor_faithful_of_injective
    {M N : Type*} [Monoid M] [Monoid N]
    (f : M →* N) (hf : Function.Injective f) :
    f.toFunctor.Faithful where
  map_injective := by
    intro X Y a b h
    exact hf h

#print axioms basedTransportFunctor_map_injective
#print axioms basedTransportFunctor_faithful
#print axioms pushoutI_of_injective_of_subsingleton
#print axioms subsingleton_factor_of_pushoutI
#print axioms monoidHom_toFunctor_faithful_of_injective

import Mathlib.GroupTheory.PushoutI
import Mathlib.AlgebraicTopology.FundamentalGroupoid.SimplyConnected
import Mathlib.CategoryTheory.Limits.Shapes.Pullback.PullbackCone

open CategoryTheory CategoryTheory.Limits

universe u v

/-- The conjugation map underlying based transport, typed in the source
category before it is used as a morphism of a single-object category. -/
def basedTransportMap {C : Type u} [Groupoid.{v} C]
    (c : C) (p : ∀ x : C, c ⟶ x)
    {x y : C} (f : x ⟶ y) : End c :=
  p x ≫ f ≫ Groupoid.inv (p y)

/-- Transport a connected groupoid to the vertex group at a chosen base object,
using one chosen arrow from the base to every object. -/
def basedTransportFunctor {C : Type u} [Groupoid.{v} C]
    (c : C) (p : ∀ x : C, c ⟶ x) :
    C ⥤ SingleObj (End c) where
  obj _ := SingleObj.star _
  map f := basedTransportMap c p f
  map_id x := by
    change basedTransportMap c p (𝟙 x) = (1 : End c)
    simp [basedTransportMap]
  map_comp f g := by
    change basedTransportMap c p (f ≫ g) =
      basedTransportMap c p g * basedTransportMap c p f
    rw [End.mul_def]
    simp [basedTransportMap, Category.assoc]

/-- Conjugating by chosen base arrows is injective on every hom-set. -/
theorem basedTransportMap_injective
    {C : Type u} [Groupoid.{v} C]
    (c : C) (p : ∀ x : C, c ⟶ x) {x y : C} :
    Function.Injective (basedTransportMap c p : (x ⟶ y) → End c) := by
  intro f g h
  dsimp only [basedTransportMap] at h
  rw [← cancel_epi (p x), ← cancel_mono (Groupoid.inv (p y))]
  simpa only [Category.assoc] using h

instance basedTransportFunctor_faithful
    {C : Type u} [Groupoid.{v} C]
    (c : C) (p : ∀ x : C, c ⟶ x) :
    (basedTransportFunctor c p).Faithful where
  map_injective {_ _} f g h := basedTransportMap_injective c p h

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

#print axioms basedTransportMap_injective
#print axioms basedTransportFunctor_faithful
#print axioms pushoutI_of_injective_of_subsingleton
#print axioms subsingleton_factor_of_pushoutI
#print axioms monoidHom_toFunctor_faithful_of_injective

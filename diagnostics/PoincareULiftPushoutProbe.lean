import Mathlib.GroupTheory.PushoutI
import Mathlib.CategoryTheory.Category.ULift
import Mathlib.CategoryTheory.Limits.Shapes.Pullback.PullbackCone
import Mathlib.CategoryTheory.Groupoid.Grpd.Basic

open CategoryTheory CategoryTheory.Limits

attribute [local instance] uliftCategory

universe u v w

noncomputable local instance uliftGroupoid
    {C : Type w} [Groupoid.{v} C] :
    Groupoid.{v} (ULift.{u} C) :=
  Groupoid.ofIsIso (fun f => inferInstance)

/-- A one-object groupoid with object universe lifted independently of its
morphism/group universe. -/
abbrev LiftedSingleObjGrpd (K : Type v) [Group K] : Grpd.{v, u} :=
  Grpd.of (ULift.{u} (SingleObj K))

/-- Universe-lift a monoid homomorphism functor without changing its map on
morphisms. -/
def liftedMonoidHomFunctor {M N : Type v} [Monoid M] [Monoid N]
    (f : M →* N) :
    LiftedSingleObjGrpd (u := u) M ⟶ LiftedSingleObjGrpd (u := u) N :=
  ULift.downFunctor ⋙ f.toFunctor ⋙ ULift.upFunctor

theorem liftedMonoidHomFunctor_faithful_of_injective
    {M N : Type v} [Monoid M] [Monoid N]
    (f : M →* N) (hf : Function.Injective f) :
    (liftedMonoidHomFunctor (u := u) f).Faithful where
  map_injective := by
    intro X Y a b h
    exact hf h

variable {H : Type v} {G : Bool → Type v}
variable [Group H] [∀ i, Group (G i)]

/-- The amalgamated group pushout, packaged as a universe-correct groupoid
pushout cocone. -/
def liftedPushoutICocone
    (φ : ∀ i, H →* G i) :
    PushoutCocone
      (liftedMonoidHomFunctor (u := u) (φ false))
      (liftedMonoidHomFunctor (u := u) (φ true)) :=
  PushoutCocone.mk
    (liftedMonoidHomFunctor (u := u) (Monoid.PushoutI.of (φ := φ) false))
    (liftedMonoidHomFunctor (u := u) (Monoid.PushoutI.of (φ := φ) true))
    (by
      apply Functor.ext
      · intro X
        rfl
      · intro X Y f
        change Monoid.PushoutI.of false (φ false f) =
          Monoid.PushoutI.of true (φ true f)
        simpa using Monoid.PushoutI.of_eq_of φ f)

#print axioms liftedMonoidHomFunctor_faithful_of_injective
#print axioms liftedPushoutICocone

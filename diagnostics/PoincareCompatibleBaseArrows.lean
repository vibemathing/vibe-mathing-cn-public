import PoincareVanKampenPushoutKernel

open CategoryTheory

universe u v

/-- Extend a chosen system of base arrows across a functor whose object map is
injective. On objects in the image, the extension is forced to be the mapped
base arrow; elsewhere an arbitrary fallback arrow is used. -/
noncomputable def extendBaseArrows
    {A B : Type u} [Groupoid.{v} A] [Groupoid.{v} B]
    (F : A ⥤ B) (c : A)
    (p : ∀ a : A, c ⟶ a)
    (fallback : ∀ b : B, F.obj c ⟶ b)
    (hobj : Function.Injective F.obj) :
    ∀ b : B, F.obj c ⟶ b :=
  fun b =>
    if h : ∃ a : A, F.obj a = b then
      F.map (p (Classical.choose h)) ≫ eqToHom (Classical.choose_spec h)
    else
      fallback b

/-- On the image of the object map, `extendBaseArrows` agrees with the
functorially mapped source base arrows. -/
theorem extendBaseArrows_obj
    {A B : Type u} [Groupoid.{v} A] [Groupoid.{v} B]
    (F : A ⥤ B) (c : A)
    (p : ∀ a : A, c ⟶ a)
    (fallback : ∀ b : B, F.obj c ⟶ b)
    (hobj : Function.Injective F.obj)
    (a : A) :
    extendBaseArrows F c p fallback hobj (F.obj a) = F.map (p a) := by
  rw [extendBaseArrows]
  split
  · rename_i h
    have ha : Classical.choose h = a :=
      hobj (Classical.choose_spec h)
    cases ha
    simp
  · rename_i h
    exact (h ⟨a, rfl⟩).elim

/-- Based transport is strictly compatible with a functor when the target
base-arrow system extends the mapped source system along an injective object
map. -/
theorem basedTransportMap_map_extend
    {A B : Type u} [Groupoid.{v} A] [Groupoid.{v} B]
    (F : A ⥤ B) (c : A)
    (p : ∀ a : A, c ⟶ a)
    (fallback : ∀ b : B, F.obj c ⟶ b)
    (hobj : Function.Injective F.obj)
    {x y : A} (f : x ⟶ y) :
    basedTransportMap (F.obj c)
        (extendBaseArrows F c p fallback hobj) (F.map f) =
      F.map (basedTransportMap c p f) := by
  rw [basedTransportMap, extendBaseArrows_obj, extendBaseArrows_obj]
  rw [basedTransportMap]
  simp only [Functor.map_comp, Functor.map_inv]

/-- The previous compatibility can be stated as compatibility with the induced
endomorphism-group homomorphism. -/
theorem basedTransportMap_mapEnd_extend
    {A B : Type u} [Groupoid.{v} A] [Groupoid.{v} B]
    (F : A ⥤ B) (c : A)
    (p : ∀ a : A, c ⟶ a)
    (fallback : ∀ b : B, F.obj c ⟶ b)
    (hobj : Function.Injective F.obj)
    {x y : A} (f : x ⟶ y) :
    basedTransportMap (F.obj c)
        (extendBaseArrows F c p fallback hobj) (F.map f) =
      (F.mapEnd c) (basedTransportMap c p f) := by
  exact basedTransportMap_map_extend F c p fallback hobj f

#print axioms extendBaseArrows_obj
#print axioms basedTransportMap_map_extend
#print axioms basedTransportMap_mapEnd_extend

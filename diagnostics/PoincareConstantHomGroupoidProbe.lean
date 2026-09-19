import PoincareVanKampenPushoutKernel
import Mathlib.CategoryTheory.Groupoid.Grpd.Basic

open CategoryTheory

universe u v

/-- A groupoid whose object type is arbitrary and whose every hom-set is the
same group. Composition uses the same convention as `SingleObj`: `f ≫ g`
corresponds to `g * f`. -/
def ConstantHomGroupoid (O : Type u) (G : Type v) := O

instance constantHomGroupoidQuiver
    (O : Type u) (G : Type v) [Group G] :
    Quiver (ConstantHomGroupoid O G) where
  Hom _ _ := G

instance constantHomGroupoidCategory
    (O : Type u) (G : Type v) [Group G] :
    Category.{v} (ConstantHomGroupoid O G) where
  id _ := 1
  comp f g := g * f
  assoc f g h := by
    exact (mul_assoc h g f).symm
  id_comp f := by simp
  comp_id f := by simp

instance constantHomGroupoidGroupoid
    (O : Type u) (G : Type v) [Group G] :
    Groupoid.{v} (ConstantHomGroupoid O G) where
  inv f := f⁻¹
  inv_comp f := by simp
  comp_inv f := by simp

/-- Package the constant-hom construction as an object of `Grpd`. -/
abbrev constantHomGrpd (O : Type u) (G : Type v) [Group G] : Grpd.{v, u} :=
  Grpd.of (ConstantHomGroupoid O G)

/-- Based transport into an arbitrary group, while independently choosing the
object map. -/
def basedTransportToConstantHom
    {C : Type u} [Groupoid.{v} C]
    {O : Type u} {G : Type v} [Group G]
    (q : C → O)
    (c : C) (p : ∀ x : C, c ⟶ x)
    (ρ : End c →* G) :
    C ⥤ ConstantHomGroupoid O G where
  obj := q
  map f := ρ (basedTransportMap c p f)
  map_id x := by
    change ρ (basedTransportMap c p (𝟙 x)) = 1
    rw [show basedTransportMap c p (𝟙 x) = 1 by
      simp [basedTransportMap]]
    exact ρ.map_one
  map_comp f g := by
    change ρ (basedTransportMap c p (f ≫ g)) =
      ρ (basedTransportMap c p g) * ρ (basedTransportMap c p f)
    have h :
        basedTransportMap c p (f ≫ g) =
          basedTransportMap c p g * basedTransportMap c p f := by
      rw [End.mul_def]
      simp [basedTransportMap, Category.assoc]
    rw [h, ρ.map_mul]

/-- If the vertex-group homomorphism is injective, the constant-hom transport
functor is faithful. -/
theorem basedTransportToConstantHom_faithful
    {C : Type u} [Groupoid.{v} C]
    {O : Type u} {G : Type v} [Group G]
    (q : C → O)
    (c : C) (p : ∀ x : C, c ⟶ x)
    (ρ : End c →* G)
    (hρ : Function.Injective ρ) :
    (basedTransportToConstantHom q c p ρ).Faithful where
  map_injective := by
    intro x y f g h
    apply basedTransportMap_injective c p
    apply hρ
    exact h

#print axioms basedTransportToConstantHom_faithful

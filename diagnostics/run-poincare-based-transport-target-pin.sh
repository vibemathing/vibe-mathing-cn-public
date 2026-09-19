#!/usr/bin/env bash
set -euo pipefail

ELAN_INSTALLER_COMMIT=464c9d28395000a2a0128e07081e4956d50eced2
ELAN_INSTALLER_SHA256=a620ff1641616222c8d37c54845492004bb84d6877cdbc944dd65c1aa685bf53
LEAN_TOOLCHAIN=leanprover/lean4:v4.33.0
MATHLIB_REV=db584cd6d46c92f209a44c0f1c829460d327499d

curl --connect-timeout 15 --max-time 240 --proto '=https' --tlsv1.2 -sSf \
  -o /tmp/elan-init.sh \
  "https://raw.githubusercontent.com/leanprover/elan/${ELAN_INSTALLER_COMMIT}/elan-init.sh"
echo "${ELAN_INSTALLER_SHA256}  /tmp/elan-init.sh" | sha256sum --check --strict
sh /tmp/elan-init.sh -y --default-toolchain none
export PATH="$HOME/.elan/bin:$PATH"
elan toolchain install "$LEAN_TOOLCHAIN"

rm -rf /tmp/mathlib-based-transport
git init /tmp/mathlib-based-transport
cd /tmp/mathlib-based-transport
git remote add origin https://github.com/leanprover-community/mathlib4.git
git fetch --depth=1 origin "$MATHLIB_REV"
git checkout --detach FETCH_HEAD

test "$(cat lean-toolchain)" = "$LEAN_TOOLCHAIN"
lake exe cache get

cat > PoincareBasedTransport.lean <<'LEAN'
import Mathlib.AlgebraicTopology.FundamentalGroupoid.FundamentalGroup
import Mathlib.CategoryTheory.SingleObj

open CategoryTheory

set_option backward.isDefEq.respectTransparency false

noncomputable section

universe u v

variable {C : Type u} [Groupoid.{v} C]

/-- Transport a connected groupoid to the vertex group at a chosen base object,
using one chosen arrow from the base to every object. -/
def basedTransportFunctor (c : C) (p : ∀ x : C, c ⟶ x) :
    C ⥤ SingleObj (End c) where
  obj _ := SingleObj.star _
  map {x y} f := p x ≫ f ≫ Groupoid.inv (p y)
  map_id x := by
    simp
  map_comp f g := by
    simp [SingleObj.comp_as_mul, End.mul_def, Category.assoc]

/-- Conjugating by chosen base arrows is injective on every hom-set. -/
theorem basedTransportFunctor_map_injective
    (c : C) (p : ∀ x : C, c ⟶ x) {x y : C} :
    Function.Injective (fun f : x ⟶ y => (basedTransportFunctor c p).map f) := by
  intro f g h
  change p x ≫ f ≫ Groupoid.inv (p y) =
      p x ≫ g ≫ Groupoid.inv (p y) at h
  rw [← cancel_epi (p x), ← cancel_mono (Groupoid.inv (p y))]
  exact h

instance basedTransportFunctor_faithful
    (c : C) (p : ∀ x : C, c ⟶ x) :
    (basedTransportFunctor c p).Faithful where
  map_injective {_ _} := basedTransportFunctor_map_injective c p

#print axioms basedTransportFunctor_map_injective
LEAN

lake env lean PoincareBasedTransport.lean

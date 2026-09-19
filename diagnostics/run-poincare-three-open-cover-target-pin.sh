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

rm -rf /tmp/mathlib-three-open-cover
git init /tmp/mathlib-three-open-cover
cd /tmp/mathlib-three-open-cover
git remote add origin https://github.com/leanprover-community/mathlib4.git
git fetch --depth=1 origin "$MATHLIB_REV"
git checkout --detach FETCH_HEAD

test "$(cat lean-toolchain)" = "$LEAN_TOOLCHAIN"
lake exe cache get

cat > PoincareThreeOpenCover.lean <<'LEAN'
import Mathlib.Topology.Sets.Opens

open TopologicalSpace

universe u

variable {X : Type u} [TopologicalSpace X]

/-- The intersection-closed three-member family attached to a two-open cover. -/
def twoOpenIntersectionFamily (U V : Opens X) : Set (Opens X) :=
  {O | O = U ∨ O = V ∨ O = U ⊓ V}

@[simp]
theorem mem_twoOpenIntersectionFamily {U V O : Opens X} :
    O ∈ twoOpenIntersectionFamily U V ↔ O = U ∨ O = V ∨ O = U ⊓ V :=
  Iff.rfl

lemma twoOpenIntersectionFamily_inf_closed
    (U V A B : Opens X)
    (hA : A ∈ twoOpenIntersectionFamily U V)
    (hB : B ∈ twoOpenIntersectionFamily U V) :
    A ⊓ B ∈ twoOpenIntersectionFamily U V := by
  rcases hA with hA | hA | hA <;>
    rcases hB with hB | hB | hB <;>
    subst A <;> subst B <;>
    simp [twoOpenIntersectionFamily, inf_assoc, inf_left_comm, inf_comm]

/-- A two-open cover gives a pointwise cover by its three-member
intersection-closed refinement. -/
theorem twoOpenIntersectionFamily_covers
    (U V : Opens X) (hUV : U ⊔ V = ⊤) :
    ∀ x : X, ∃ O : Opens X,
      O ∈ twoOpenIntersectionFamily U V ∧ x ∈ O := by
  intro x
  have hx : x ∈ U ⊔ V := by
    rw [hUV]
    simp
  have hx' : x ∈ U ∨ x ∈ V := by
    simpa using hx
  rcases hx' with hxU | hxV
  · exact ⟨U, Or.inl rfl, hxU⟩
  · exact ⟨V, Or.inr (Or.inl rfl), hxV⟩

/-- The three-member family is closed under nonempty finite intersections. -/
theorem twoOpenIntersectionFamily_finiteIntersections
    (U V : Opens X) :
    ∀ s : Finset (Opens X), s.Nonempty →
      (∀ O ∈ s, O ∈ twoOpenIntersectionFamily U V) →
      s.inf (fun O : Opens X => O) ∈ twoOpenIntersectionFamily U V := by
  classical
  intro s hs hall
  induction s using Finset.induction_on with
  | empty =>
      simp at hs
  | @insert A s hA ih =>
      by_cases hs0 : s = ∅
      · subst s
        simpa using hall A (by simp)
      · have hsne : s.Nonempty := Finset.nonempty_iff_ne_empty.mpr hs0
        have hAfam : A ∈ twoOpenIntersectionFamily U V :=
          hall A (by simp)
        have hsfam : ∀ O ∈ s, O ∈ twoOpenIntersectionFamily U V := by
          intro O hO
          exact hall O (Finset.mem_insert_of_mem hO)
        have hInf := ih hsne hsfam
        rw [Finset.inf_insert]
        exact twoOpenIntersectionFamily_inf_closed U V A
          (s.inf fun O : Opens X => O) hAfam hInf

#print axioms twoOpenIntersectionFamily_inf_closed
#print axioms twoOpenIntersectionFamily_covers
#print axioms twoOpenIntersectionFamily_finiteIntersections
LEAN

lake env lean PoincareThreeOpenCover.lean

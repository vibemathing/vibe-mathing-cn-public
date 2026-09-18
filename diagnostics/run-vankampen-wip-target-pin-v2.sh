#!/usr/bin/env bash
set -euo pipefail

# Derive a diagnostic runner from the previous exact-pin harness rather than
# duplicating its bootstrap/overlay logic.
python3 - <<'PY'
from pathlib import Path

src = Path('diagnostics/run-vankampen-wip-target-pin.sh').read_text()

# Lean 4.33 has trouble reducing the FundamentalGroupoid bundled-object layer
# at the two identity-sandwich steps.  Keep the upstream proof `by simp` and
# enable the same backward-defeq compatibility mode below that already made
# ComposeMorphisms and CompositionFinal compile.  This changes elaboration
# only, not the theorem statement or mathematical assumptions.
old = '''              = 𝟙 x ≫ g ≫ 𝟙 y := by
                  simpa only [Category.id_comp] using (Category.comp_id g).symm'''
new = '''              = 𝟙 x ≫ g ≫ 𝟙 y := by simp'''
if src.count(old) != 1:
    raise SystemExit(f'unexpected uniqueness runner patch count: {src.count(old)}')
src = src.replace(old, new, 1)

# Apply the same Lean-4.33 backward-defeq compatibility setting that already
# made ComposeMorphisms compile.  With this setting the two eqToHom_trans simp
# calls fully close their goals, so remove the now-superfluous exact tactics.
inject = r'''

p = Path('Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen/UniquenessProofs.lean')
s = p.read_text()
anchor = 'open scoped unitInterval\n\nnoncomputable section'
if anchor not in s:
    raise SystemExit('UniquenessProofs transparency anchor not found')
s = s.replace(anchor,
    'open scoped unitInterval\n\nset_option backward.isDefEq.respectTransparency false\n\nnoncomputable section', 1)
p.write_text(s)

p = Path('Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen/SingleCoveredSimple.lean')
s = p.read_text()
anchor = 'open scoped unitInterval\n\nnoncomputable section'
if anchor not in s:
    raise SystemExit('SingleCoveredSimple transparency anchor not found')
s = s.replace(anchor,
    'open scoped unitInterval\n\nset_option backward.isDefEq.respectTransparency false\n\nnoncomputable section', 1)
old_tail = '      simp only [eqToHom_trans]\n      exact h_irrel _ _'
if s.count(old_tail) != 2:
    raise SystemExit(f'unexpected SingleCoveredSimple closed-goal tail count: {s.count(old_tail)}')
s = s.replace(old_tail, '      simp only [eqToHom_trans]')
p.write_text(s)

# CompositionFinal reaches only a definitional-equality residue on Lean 4.33.
# Use the same compatibility mode as ComposeMorphisms.  In h_middle, rw
# [h_comp] now closes the proof by proof irrelevance, so the following exact is
# a stale tactic and must be removed.
p = Path('Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen/CompositionFinal.lean')
s = p.read_text()
anchor = 'open scoped unitInterval\n\nnoncomputable section'
if anchor not in s:
    raise SystemExit('CompositionFinal transparency anchor not found')
s = s.replace(anchor,
    'open scoped unitInterval\n\nset_option backward.isDefEq.respectTransparency false\n\nnoncomputable section', 1)
old_middle = '      rw [h_comp]\n      exact h_eqToHom_congr _ _'
if s.count(old_middle) != 1:
    raise SystemExit(f'unexpected CompositionFinal h_middle patch count: {s.count(old_middle)}')
s = s.replace(old_middle, '      rw [h_comp]', 1)
p.write_text(s)

# ColimitProof is the next Lean-4.33 compatibility frontier exposed after
# UniquenessProofs compiled.  Its remaining residues are eqToHom/Functor.map
# definitional-equality failures, including an explicit implicit-transparency
# diagnostic from Lean.  Apply the same elaboration-only compatibility mode.
p = Path('Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen/ColimitProof.lean')
s = p.read_text()
anchor = 'open scoped unitInterval\n\nnoncomputable section'
if anchor not in s:
    raise SystemExit('ColimitProof transparency anchor not found')
s = s.replace(anchor,
    'open scoped unitInterval\n\nset_option backward.isDefEq.respectTransparency false\n\nnoncomputable section', 1)
p.write_text(s)
'''
marker = "PY\n\nlake exe cache get"
if src.count(marker) != 1:
    raise SystemExit(f'unexpected final runner marker count: {src.count(marker)}')
src = src.replace(marker, inject + "\nPY\n\nlake exe cache get", 1)

Path('/tmp/run-vankampen-wip-target-pin-v2-generated.sh').write_text(src)
PY

bash /tmp/run-vankampen-wip-target-pin-v2-generated.sh

# If the full exact-pin build succeeds, audit the final colimit declarations at
# theorem level.  This is deliberately after the build so failed elaboration
# cannot produce misleading downstream axiom output.
cd /tmp/mathlib-target
cat > PoincareVanKampenAxiomAudit.lean <<'LEAN'
import Mathlib.AlgebraicTopology.FundamentalGroupoid.VanKampen.IsColimit

#print axioms my_canonicalCocone_isColimit
#print axioms van_kampen_groupoid_main
#print axioms uniqueness_full
LEAN
"$HOME/.elan/bin/lake" env lean PoincareVanKampenAxiomAudit.lean

# Downstream categorical bridge toward connected-sum factor simple-connectivity:
# a thin colimit apex forces any diagram object with a faithful test-cocone leg
# to be thin as well.
cat > PoincareVanKampenFaithfulLeg.lean <<'LEAN'
import Mathlib.AlgebraicTopology.FundamentalGroupoid.VanKampen.IsColimit

open CategoryTheory CategoryTheory.Limits

universe u v

variable {J : Type u} [Category.{v} J]
variable (D : J ⥤ Grpd)

/-- If a colimit apex is thin and the same diagram admits a cocone whose
chosen leg is faithful, then the corresponding groupoid has subsingleton hom-sets. -/
theorem subsingleton_hom_of_isColimit_faithful_leg
    (c : Cocone D) (hc : IsColimit c)
    (hthin : ∀ x y : c.pt, Subsingleton (x ⟶ y))
    (s : Cocone D) (j : J) [(s.ι.app j).Faithful] :
    ∀ x y : D.obj j, Subsingleton (x ⟶ y) := by
  intro x y
  constructor
  intro f g
  apply (s.ι.app j).map_injective
  have hfg : (c.ι.app j).map f = (c.ι.app j).map g :=
    @Subsingleton.elim _ (hthin _ _) _ _
  have hmapped := congrArg (hc.desc s).map hfg
  have hfac_f := congrArg (fun F : D.obj j ⥤ s.pt => F.map f) (hc.fac s j)
  have hfac_g := congrArg (fun F : D.obj j ⥤ s.pt => F.map g) (hc.fac s j)
  calc
    (s.ι.app j).map f =
        (hc.desc s).map ((c.ι.app j).map f) := by
      simpa only [Functor.comp_map] using hfac_f.symm
    _ = (hc.desc s).map ((c.ι.app j).map g) := hmapped
    _ = (s.ι.app j).map g := by
      simpa only [Functor.comp_map] using hfac_g

universe u₁ v₁

variable {C : Type u₁} [Groupoid.{v₁} C]

/-- A choice of arrows from a base object to every object gives a one-object
transport functor into the base endomorphism group. -/
def basedTransportFunctor (c : C) (p : ∀ x : C, c ⟶ x) :
    C ⥤ SingleObj (End c) where
  obj _ := SingleObj.star _
  map {x y} f := p x ≫ f ≫ inv (p y)
  map_id x := by
    simp
  map_comp f g := by
    simp only [SingleObj.comp_as_mul, End.mul_def, Category.assoc,
      IsIso.inv_hom_id_assoc]

/-- The based transport functor is faithful: conjugating a morphism by chosen
base arrows cannot identify two distinct morphisms. -/
theorem basedTransportFunctor_map_injective (c : C) (p : ∀ x : C, c ⟶ x)
    {x y : C} :
    Function.Injective (fun f : x ⟶ y => (basedTransportFunctor c p).map f) := by
  intro f g h
  rw [← cancel_epi (p x), ← cancel_mono (inv (p y))]
  simpa [basedTransportFunctor, Category.assoc] using h

instance basedTransportFunctor_faithful (c : C) (p : ∀ x : C, c ⟶ x) :
    (basedTransportFunctor c p).Faithful where
  map_injective := basedTransportFunctor_map_injective c p

universe u₂

variable {X : Type u₂} [TopologicalSpace X]

/-- The intersection-closed family of all opens subordinate to one side of a
two-open cover. -/
def subordinateTwoCover (U V : Opens X) : Set (Opens X) :=
  {O | O ≤ U ∨ O ≤ V}

@[simp]
theorem mem_subordinateTwoCover {U V O : Opens X} :
    O ∈ subordinateTwoCover U V ↔ O ≤ U ∨ O ≤ V :=
  Iff.rfl

/-- If U and V cover X, the subordinate family covers X as well. -/
theorem subordinateTwoCover_covers (U V : Opens X) (hUV : U ⊔ V = ⊤) :
    ∀ x : X, ∃ O : Opens X, O ∈ subordinateTwoCover U V ∧ x ∈ O := by
  intro x
  have hx : x ∈ U ⊔ V := by
    rw [hUV]
    simp
  rcases (Opens.mem_sup.mp hx) with hxU | hxV
  · exact ⟨U, Or.inl le_rfl, hxU⟩
  · exact ⟨V, Or.inr le_rfl, hxV⟩

/-- The subordinate family is closed under nonempty finite intersections. -/
theorem subordinateTwoCover_finiteIntersections (U V : Opens X) :
    ∀ s : Finset (Opens X), s.Nonempty →
      (∀ O ∈ s, O ∈ subordinateTwoCover U V) →
      s.inf (fun O : Opens X => O) ∈ subordinateTwoCover U V := by
  intro s hs hall
  rcases hs with ⟨O, hO⟩
  rcases hall O hO with hOU | hOV
  · exact Or.inl ((Finset.inf_le hO).trans hOU)
  · exact Or.inr ((Finset.inf_le hO).trans hOV)

#print axioms subsingleton_hom_of_isColimit_faithful_leg
#print axioms basedTransportFunctor_map_injective
#print axioms subordinateTwoCover_covers
#print axioms subordinateTwoCover_finiteIntersections
LEAN
"$HOME/.elan/bin/lake" env lean PoincareVanKampenFaithfulLeg.lean

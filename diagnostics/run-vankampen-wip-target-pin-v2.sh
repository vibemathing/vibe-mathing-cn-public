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
open TopologicalSpace

set_option backward.isDefEq.respectTransparency false

universe u v

variable {J : Type u} [Category.{v} J]
variable (D : J ⥤ Grpd)

/-- If a colimit apex is thin and the same diagram admits a cocone whose
chosen leg is faithful, then the corresponding diagram object is thin. -/
theorem subsingleton_hom_of_isColimit_faithful_leg
    (c : Cocone D) (hc : IsColimit c)
    (hthin : ∀ x y : c.pt, Subsingleton (x ⟶ y))
    (s : Cocone D) (j : J) [(s.ι.app j).Faithful] :
    ∀ x y : D.obj j, Subsingleton (x ⟶ y) := by
  intro x y
  constructor
  intro f g
  let F := c.ι.app j ⋙ hc.desc s
  have hF : F = s.ι.app j := by
    dsimp [F]
    have hfac := hc.fac s j
    rw [Grpd.comp_eq_comp] at hfac
    exact hfac
  haveI : F.Faithful := by
    rw [hF]
    infer_instance
  have hfg :
      (c.ι.app j).map f = (c.ι.app j).map g :=
    @Subsingleton.elim _ (hthin _ _) _ _
  apply F.map_injective
  exact congrArg (hc.desc s).map hfg

universe u₂

variable {X : Type u₂} [TopologicalSpace X]

/-- Full groupoid Van Kampen plus a faithful test-cocone leg transfers
simple connectivity of the ambient space to a path-connected cover member. -/
theorem simplyConnectedSpace_of_vankampen_faithful_leg
    (X : Type u₂) [TopologicalSpace X]
    (𝒰 : Set (Opens X))
    (hcover : ∀ x : X, ∃ O : Opens X, O ∈ 𝒰 ∧ x ∈ O)
    (hfinite :
      ∀ t : Finset (Opens X), t.Nonempty →
        (∀ O ∈ t, O ∈ 𝒰) →
        t.inf (fun O : Opens X => O) ∈ 𝒰)
    [SimplyConnectedSpace X]
    (U : Opens X) (hU : U ∈ 𝒰)
    [PathConnectedSpace U]
    (s : Cocone
      (((Subtype.mono_coe (fun O : Opens X => O ∈ 𝒰)).functor) ⋙
        Opens.toTopCat (TopCat.of X) ⋙
        FundamentalGroupoid.fundamentalGroupoidFunctor))
    [(s.ι.app ⟨U, hU⟩).Faithful] :
    SimplyConnectedSpace U := by
  let D :=
    (((Subtype.mono_coe (fun O : Opens X => O ∈ 𝒰)).functor) ⋙
      Opens.toTopCat (TopCat.of X) ⋙
      FundamentalGroupoid.fundamentalGroupoidFunctor)
  let c := canonicalCocone X 𝒰
  let hc := my_canonicalCocone_isColimit X 𝒰 hcover hfinite
  have hthinX : ∀ x y : c.pt, Subsingleton (x ⟶ y) := by
    intro x y
    change Subsingleton (Path.Homotopic.Quotient x.as y.as)
    infer_instance
  have hthinU :
      ∀ x y : D.obj ⟨U, hU⟩, Subsingleton (x ⟶ y) :=
    subsingleton_hom_of_isColimit_faithful_leg D c hc hthinX s ⟨U, hU⟩
  rw [simply_connected_iff_paths_homotopic]
  refine ⟨inferInstance, ?_⟩
  intro x y
  change Subsingleton
    ((FundamentalGroupoid.mk x : FundamentalGroupoid U) ⟶
      (FundamentalGroupoid.mk y : FundamentalGroupoid U))
  exact hthinU _ _

#print axioms subsingleton_hom_of_isColimit_faithful_leg
#print axioms simplyConnectedSpace_of_vankampen_faithful_leg
LEAN
"$HOME/.elan/bin/lake" env lean PoincareVanKampenFaithfulLeg.lean

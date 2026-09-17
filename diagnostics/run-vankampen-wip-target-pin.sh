#!/usr/bin/env bash
set -euo pipefail

ELAN_INSTALLER_COMMIT=464c9d28395000a2a0128e07081e4956d50eced2
ELAN_INSTALLER_SHA256=a620ff1641616222c8d37c54845492004bb84d6877cdbc944dd65c1aa685bf53
LEAN_TOOLCHAIN=leanprover/lean4:v4.33.0
MATHLIB_REV=db584cd6d46c92f209a44c0f1c829460d327499d
VK_REV=9a19745bf2565abbbf56bb38c91bcd26c4c53b49

curl --connect-timeout 15 --max-time 240 --proto '=https' --tlsv1.2 -sSf \
  -o /tmp/elan-init.sh \
  "https://raw.githubusercontent.com/leanprover/elan/${ELAN_INSTALLER_COMMIT}/elan-init.sh"
echo "${ELAN_INSTALLER_SHA256}  /tmp/elan-init.sh" | sha256sum --check --strict
sh /tmp/elan-init.sh -y --default-toolchain none
export PATH="$HOME/.elan/bin:$PATH"
elan toolchain install "$LEAN_TOOLCHAIN"

rm -rf /tmp/mathlib-target
git init /tmp/mathlib-target
cd /tmp/mathlib-target
git remote add origin https://github.com/leanprover-community/mathlib4.git
git fetch --depth=1 origin "$MATHLIB_REV"
git checkout --detach FETCH_HEAD
git remote add vk https://github.com/hanwenzhu/mathlib4.git
git fetch --depth=1 vk "$VK_REV"
git checkout FETCH_HEAD -- Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen

test "$(cat lean-toolchain)" = "$LEAN_TOOLCHAIN"

python3 - <<'PY'
from pathlib import Path

p = Path('Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen/ComposeMorphisms.lean')
s = p.read_text()
anchor = 'open CategoryTheory\nvariable {C : Type*} [Groupoid C]'
if anchor not in s:
    raise SystemExit('ComposeMorphisms anchor not found')
s = s.replace(anchor,
    anchor + '\nset_option backward.isDefEq.respectTransparency false', 1)
repls = {
'''  have h_step2 : eqToHom h0.symm ≫ (comp_list k objs_mid homs_mid ≫ homs' (Fin.last k)) ≫ eqToHom h_last =
      (eqToHom h0.symm ≫ comp_list k objs_mid homs_mid) ≫ (homs' (Fin.last k) ≫ eqToHom h_last) := by
    simp [Category.assoc] <;> rfl''':
'''  have h_step2 : eqToHom h0.symm ≫ (comp_list k objs_mid homs_mid ≫ homs' (Fin.last k)) ≫ eqToHom h_last =
      (eqToHom h0.symm ≫ comp_list k objs_mid homs_mid) ≫ (homs' (Fin.last k) ≫ eqToHom h_last) := by
    simp only [Category.assoc]''',
'''      have h_step2 : f ≫ (g ≫ last) ≫ eqToHom h_end = (f ≫ g) ≫ last ≫ eqToHom h_end := by
        simp [Category.assoc] <;> rfl''':
'''      have h_step2 : f ≫ (g ≫ last) ≫ eqToHom h_end = (f ≫ g) ≫ last ≫ eqToHom h_end := by
        simp only [Category.assoc]''',
'''      have h_step3 : (f ≫ g) ≫ last ≫ eqToHom h_end = (f ≫ g) ≫ (last ≫ eqToHom h_end) := by
        simp [Category.assoc] <;> rfl''':
'''      have h_step3 : (f ≫ g) ≫ last ≫ eqToHom h_end = (f ≫ g) ≫ (last ≫ eqToHom h_end) := by
        simp only [Category.assoc]''',
'''      have h_step5 : (f ≫ g) ≫ (eqToHom h_mid ≫ last_hom) = (f ≫ g ≫ eqToHom h_mid) ≫ last_hom := by
        simp [Category.assoc] <;> rfl''':
'''      have h_step5 : (f ≫ g) ≫ (eqToHom h_mid ≫ last_hom) = (f ≫ g ≫ eqToHom h_mid) ≫ last_hom := by
        simp only [Category.assoc]''',
'''      have h_step7 : (comp_list n objs₁ homs₁ ≫ eqToHom h_match ≫ comp_list m objs₂' homs₂') ≫ last_hom =
          comp_list n objs₁ homs₁ ≫ eqToHom h_match ≫ (comp_list m objs₂' homs₂' ≫ last_hom) := by
        simp [Category.assoc] <;> rfl''':
'''      have h_step7 : (comp_list n objs₁ homs₁ ≫ eqToHom h_match ≫ comp_list m objs₂' homs₂') ≫ last_hom =
          comp_list n objs₁ homs₁ ≫ eqToHom h_match ≫ (comp_list m objs₂' homs₂' ≫ last_hom) := by
        simp only [Category.assoc]'''
}
for old,new in repls.items():
    if old not in s:
        raise SystemExit('expected ComposeMorphisms patch block not found')
    s=s.replace(old,new,1)
p.write_text(s)

# Lean 4.33 no longer closes the two identity-sandwich steps in the uniqueness
# calculation with an unqualified `simp`; spell out the categorical identity
# law while leaving the theorem statement and mathematical proof unchanged.
p = Path('Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen/UniquenessProofs.lean')
s = p.read_text()
old = '''            g
              = 𝟙 x ≫ g ≫ 𝟙 y := by simp'''
new = '''            g
              = 𝟙 x ≫ g ≫ 𝟙 y := by
                  simpa only [Category.id_comp] using (Category.comp_id g).symm'''
if s.count(old) != 2:
    raise SystemExit(f'unexpected uniqueness identity-sandwich count: {s.count(old)}')
s = s.replace(old, new)
p.write_text(s)

p = Path('Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen/SingleCoveredSimple.lean')
s = p.read_text()
old = '''    -- Now simplify using associativity and proof irrelevance
    simp [Category.assoc, eqToHom_trans]
    <;>
    (try { congr <;> exact Subsingleton.elim _ _ })
    <;>
    aesop'''
new = '''    -- Collapse the three equality transports on each side explicitly.
    -- This avoids asking automation to solve a dependent `HEq` goal.
    have h_irrel : ∀ {A B : s.pt} (p q : A = B), eqToHom p = eqToHom q := by
      intro A B p q
      congr <;> exact Subsingleton.elim _ _
    have h_left :
        eqToHom h_eq_x.symm ≫
            (eqToHom h_eq1_W.symm ≫
              eqToHom (congr_arg
                (fun (K : _ ⥤ _) =>
                  K.obj (FundamentalGroupoid.mk (⟨x, hxW⟩ : W_set)))
                h_nat.symm)) =
          eqToHom h_eq1_U.symm := by
      simp only [eqToHom_trans]
      exact h_irrel _ _
    have h_right :
        eqToHom (congr_arg
              (fun (K : _ ⥤ _) =>
                K.obj (FundamentalGroupoid.mk (⟨y, hyW⟩ : W_set)))
              h_nat.symm).symm ≫
            (eqToHom h_eq2_W ≫ eqToHom h_eq_y) =
          eqToHom h_eq2_U := by
      simp only [eqToHom_trans]
      exact h_irrel _ _
    dsimp [f_U_core]
    calc
      eqToHom h_eq_x.symm ≫
          (eqToHom h_eq1_W.symm ≫
            (eqToHom (congr_arg
                (fun (K : _ ⥤ _) =>
                  K.obj (FundamentalGroupoid.mk (⟨x, hxW⟩ : W_set)))
                h_nat.symm) ≫
              F_U.map γ_U_class ≫
              eqToHom (congr_arg
                (fun (K : _ ⥤ _) =>
                  K.obj (FundamentalGroupoid.mk (⟨y, hyW⟩ : W_set)))
                h_nat.symm).symm) ≫
            eqToHom h_eq2_W) ≫ eqToHom h_eq_y
        = (eqToHom h_eq_x.symm ≫
            (eqToHom h_eq1_W.symm ≫
              eqToHom (congr_arg
                (fun (K : _ ⥤ _) =>
                  K.obj (FundamentalGroupoid.mk (⟨x, hxW⟩ : W_set)))
                h_nat.symm))) ≫
            F_U.map γ_U_class ≫
            (eqToHom (congr_arg
                (fun (K : _ ⥤ _) =>
                  K.obj (FundamentalGroupoid.mk (⟨y, hyW⟩ : W_set)))
                h_nat.symm).symm ≫
              (eqToHom h_eq2_W ≫ eqToHom h_eq_y)) := by
            simp only [Category.assoc]
      _ = eqToHom h_eq1_U.symm ≫ F_U.map γ_U_class ≫ eqToHom h_eq2_U := by
            rw [h_left, h_right]'''
if s.count(old) != 1:
    raise SystemExit(f'unexpected SingleCoveredSimple tail count: {s.count(old)}')
s = s.replace(old, new, 1)
p.write_text(s)
PY

lake exe cache get
lake build Mathlib.AlgebraicTopology.FundamentalGroupoid.VanKampen.IsColimit

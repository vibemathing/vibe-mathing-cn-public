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
# Lean 4.33 is stricter about dependent object transports in this WIP source.
# Apply the same backward-defeq transparency relaxation used elsewhere in pinned
# Mathlib, at file scope in this disposable overlay. Statements are unchanged.
anchor = 'open CategoryTheory\nvariable {C : Type*} [Groupoid C]'
if anchor not in s:
    raise SystemExit('ComposeMorphisms anchor not found')
s = s.replace(anchor,
    anchor + '\nset_option backward.isDefEq.respectTransparency false', 1)

# Normalize category reassociation explicitly instead of relying on 4.32
# definitional equality.
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

p = Path('Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen/SingleCoveredSimple.lean')
s=p.read_text()
old='''    -- Now simplify using associativity and proof irrelevance
    simp [Category.assoc, eqToHom_trans]
    <;>
    (try { congr <;> exact Subsingleton.elim _ _ })
    <;>
    aesop'''
new='''    -- Normalize equality transports using the local proof-irrelevance lemma.
    -- The remaining morphism equality is then the naturality equality already
    -- established above; do not ask for a Subsingleton instance on the hom-set.
    simp [Category.assoc, eqToHom_trans, h_irrel]
    <;> aesop'''
if old not in s:
    raise SystemExit('expected SingleCoveredSimple tail not found')
p.write_text(s.replace(old,new,1))
PY

lake exe cache get
lake build Mathlib.AlgebraicTopology.FundamentalGroupoid.VanKampen.IsColimit

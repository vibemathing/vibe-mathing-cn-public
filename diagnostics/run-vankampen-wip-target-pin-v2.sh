#!/usr/bin/env bash
set -euo pipefail

# Derive a diagnostic runner from the previous exact-pin harness rather than
# duplicating its bootstrap/overlay logic.
python3 - <<'PY'
from pathlib import Path

src = Path('diagnostics/run-vankampen-wip-target-pin.sh').read_text()

# Lean 4.33 leaves the right identity goal after simplifying the left identity.
# Give `g` its FundamentalGroupoid hom type explicitly, then apply the category
# right-unit theorem as an exact proof instead of relying on simp transparency.
old = '''              = 𝟙 x ≫ g ≫ 𝟙 y := by
                  simpa only [Category.id_comp] using (Category.comp_id g).symm'''
new = '''              = 𝟙 x ≫ g ≫ 𝟙 y := by
                  change (g : x ⟶ y) = 𝟙 x ≫ (g : x ⟶ y) ≫ 𝟙 y
                  rw [Category.id_comp]
                  exact (Category.comp_id (g : x ⟶ y)).symm'''
if src.count(old) != 1:
    raise SystemExit(f'unexpected uniqueness runner patch count: {src.count(old)}')
src = src.replace(old, new, 1)

# Apply the same Lean-4.33 backward-defeq compatibility setting that already
# made ComposeMorphisms compile.  With this setting the two eqToHom_trans simp
# calls fully close their goals, so remove the now-superfluous exact tactics.
inject = r'''

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
'''
marker = "PY\n\nlake exe cache get"
if src.count(marker) != 1:
    raise SystemExit(f'unexpected final runner marker count: {src.count(marker)}')
src = src.replace(marker, inject + "\nPY\n\nlake exe cache get", 1)

Path('/tmp/run-vankampen-wip-target-pin-v2-generated.sh').write_text(src)
PY

bash /tmp/run-vankampen-wip-target-pin-v2-generated.sh

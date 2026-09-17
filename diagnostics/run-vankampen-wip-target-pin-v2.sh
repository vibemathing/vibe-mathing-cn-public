#!/usr/bin/env bash
set -euo pipefail

# Derive a second diagnostic runner from the previous exact-pin harness rather
# than duplicating its bootstrap/overlay logic.  The old runner is diagnostic
# only; this file rewrites its patch payload before executing it.
python3 - <<'PY'
from pathlib import Path

src = Path('diagnostics/run-vankampen-wip-target-pin.sh').read_text()

# The previous experiment tried Category.comp_id on `g` while Lean still saw
# the underlying Path.Homotopic.Quotient type.  Force the definitional
# FundamentalGroupoid hom type before invoking the category laws.
old = '''              = 𝟙 x ≫ g ≫ 𝟙 y := by
                  simpa only [Category.id_comp] using (Category.comp_id g).symm'''
new = '''              = 𝟙 x ≫ g ≫ 𝟙 y := by
                  change (g : x ⟶ y) = 𝟙 x ≫ (g : x ⟶ y) ≫ 𝟙 y
                  simp only [Category.id_comp, Category.comp_id]'''
if src.count(old) != 1:
    raise SystemExit(f'unexpected uniqueness runner patch count: {src.count(old)}')
src = src.replace(old, new, 1)

# Apply the same Lean-4.33 backward-defeq compatibility setting that already
# made ComposeMorphisms compile, but only in SingleCoveredSimple.  The theorem
# statements and proof terms are otherwise unchanged by this insertion.
inject = r'''

# Lean 4.33 is stricter about the definitional equality between the composed
# diagram functors and the local let-bound F_W/F_U aliases in this file.
p = Path('Mathlib/AlgebraicTopology/FundamentalGroupoid/VanKampen/SingleCoveredSimple.lean')
s = p.read_text()
anchor = 'open scoped unitInterval\n\nnoncomputable section'
if anchor not in s:
    raise SystemExit('SingleCoveredSimple transparency anchor not found')
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

#!/usr/bin/env bash
set -euo pipefail

ELAN_INSTALLER_COMMIT=464c9d28395000a2a0128e07081e4956d50eced2
ELAN_INSTALLER_SHA256=a620ff1641616222c8d37c54845492004bb84d6877cdbc944dd65c1aa685bf53
LEAN_TOOLCHAIN=leanprover/lean4:v4.33.0
MATHLIB_REV=db584cd6d46c92f209a44c0f1c829460d327499d
HATCHER_REPO_COMMIT=bb91a091f0b968f8bbe8d861e025a88d82b161be

curl --connect-timeout 15 --max-time 240 --proto '=https' --tlsv1.2 -sSf \
  -o /tmp/elan-init.sh \
  "https://raw.githubusercontent.com/leanprover/elan/${ELAN_INSTALLER_COMMIT}/elan-init.sh"
echo "${ELAN_INSTALLER_SHA256}  /tmp/elan-init.sh" | sha256sum --check --strict
sh /tmp/elan-init.sh -y --default-toolchain none
export PATH="$HOME/.elan/bin:$PATH"
elan toolchain install "$LEAN_TOOLCHAIN"

rm -rf /tmp/poincare-src
git clone --filter=blob:none --no-checkout \
  https://github.com/frenzymath/Poincare-Conjecture.git /tmp/poincare-src
cd /tmp/poincare-src
git fetch --depth=1 origin "$HATCHER_REPO_COMMIT"
git checkout --detach FETCH_HEAD
cd formalized-sources/Hatcher
printf '%s\n' "$LEAN_TOOLCHAIN" > lean-toolchain

python3 - <<'PY'
from pathlib import Path

MATHLIB_OLD = '520045ab14e26149ee970e2e617ca04b09bde5d6'
MATHLIB_NEW = 'db584cd6d46c92f209a44c0f1c829460d327499d'

p = Path('lakefile.lean')
s = p.read_text()
if MATHLIB_OLD not in s:
    raise SystemExit('old Mathlib pin not found')
p.write_text(s.replace(MATHLIB_OLD, MATHLIB_NEW))

# Lean 4.33 transparency migration in mapOfEq. Mathematical statements unchanged.
p = Path('HatcherLib/Ch1/BasicConstructions.lean')
s = p.read_text()
old = '(_root_.FundamentalGroup.mapOfEq (ContinuousMap.id Y) h).comp'
new = "(_root_.FundamentalGroup.mapOfEq (ContinuousMap.id Y)\n        (by simpa using h)).comp"
if s.count(old) != 2:
    raise SystemExit(f'unexpected mapOfEq identity occurrence count: {s.count(old)}')
p.write_text(s.replace(old, new))

p = Path('HatcherLib/Ch1/VanKampen.lean')
s = p.read_text()

# The original definition relies on reducing the image basepoint
# `(coverInclusion cover i) ⟨x₀, proof⟩` definitionally to `x₀`.
# Lean 4.33 is more conservative at the free-product elaboration site, so use
# Mathlib's explicit basepoint-transporting homomorphism. The statement and map
# on path classes are unchanged.
old_def = '''  freeProductLift _ fun i =>
    FundamentalGroup.map (coverInclusion cover i) ⟨x₀, cover.base_mem i⟩'''
new_def = '''  freeProductLift _ fun i =>
    FundamentalGroup.mapOfEq (coverInclusion cover i)
      (by rfl : (coverInclusion cover i) ⟨x₀, cover.base_mem i⟩ = x₀)'''
if s.count(old_def) != 1:
    raise SystemExit(f'unexpected vanKampenMap definition count: {s.count(old_def)}')
s = s.replace(old_def, new_def)

old_proof = '''  rw [vanKampenMap, freeProductLift, freeProductInclusion,
    Monoid.CoprodI.lift_of]
  change Path.Homotopic.Quotient.map'''
new_proof = '''  rw [vanKampenMap, ← MonoidHom.comp_apply, freeProductLift_comp_inclusion,
    FundamentalGroup.mapOfEq_apply]
  change Path.Homotopic.Quotient.map'''
if s.count(old_proof) != 1:
    raise SystemExit(f'unexpected vanKampenMap_factor proof block count: {s.count(old_proof)}')
s = s.replace(old_proof, new_proof)
p.write_text(s)
PY

cat > HatcherLib/Ch1/PoincareVanKampenBridge.lean <<'LEAN'
import HatcherLib.Ch1.VanKampenGlobalSweep

namespace HatcherLib
noncomputable section
universe u
variable {X : Type u} [TopologicalSpace X] {x₀ : X}

/-- For a two-member cover, pairwise intersection path-connectedness already
supplies every threefold-intersection condition used by the grid sweep. -/
theorem boolCover_tripleIntersectionsPathConnected
    (cover : PathConnectedOpenCover x₀ Bool) :
    VanKampenTripleIntersectionsPathConnected cover := by
  intro i j k
  cases i <;> cases j <;> cases k
  · simpa [Set.inter_assoc, Set.inter_left_comm, Set.inter_comm] using cover.pathConnected false
  · simpa [Set.inter_assoc, Set.inter_left_comm, Set.inter_comm] using cover.interPathConnected false true
  · simpa [Set.inter_assoc, Set.inter_left_comm, Set.inter_comm] using cover.interPathConnected false true
  · simpa [Set.inter_assoc, Set.inter_left_comm, Set.inter_comm] using cover.interPathConnected false true
  · simpa [Set.inter_assoc, Set.inter_left_comm, Set.inter_comm] using cover.interPathConnected true false
  · simpa [Set.inter_assoc, Set.inter_left_comm, Set.inter_comm] using cover.interPathConnected true false
  · simpa [Set.inter_assoc, Set.inter_left_comm, Set.inter_comm] using cover.interPathConnected true false
  · simpa [Set.inter_assoc, Set.inter_left_comm, Set.inter_comm] using cover.pathConnected true

end
end HatcherLib
LEAN

rm -f lake-manifest.json
lake update mathlib
test "$(cat lean-toolchain)" = "$LEAN_TOOLCHAIN"
grep -q "$MATHLIB_REV" lakefile.lean
lake exe cache get
lake build \
  HatcherLib.Ch1.VanKampenGlobalSweep \
  HatcherLib.Ch1.VanKampenAdaptedGrid \
  HatcherLib.Ch1.PoincareVanKampenBridge

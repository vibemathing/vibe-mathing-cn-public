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

p = Path('HatcherLib/Ch1/BasicConstructions.lean')
s = p.read_text()
old = '(_root_.FundamentalGroup.mapOfEq (ContinuousMap.id Y) h).comp'
new = "(_root_.FundamentalGroup.mapOfEq (ContinuousMap.id Y)\n        (by simpa using h)).comp"
if s.count(old) != 2:
    raise SystemExit(f'unexpected mapOfEq identity occurrence count: {s.count(old)}')
p.write_text(s.replace(old, new))

p = Path('HatcherLib/Ch1/VanKampen.lean')
s = p.read_text()
old_def = '''/-- The homomorphism from the free product of the fundamental groups of the
cover members to the fundamental group of the ambient space. -/
def vanKampenMap {x₀ : X} {ι : Type v}
    (cover : PathConnectedOpenCover x₀ ι) :
    FreeProduct (fun i => CoverFundamentalGroup cover i) →*
      FundamentalGroup X x₀ :=
  freeProductLift _ fun i =>
    FundamentalGroup.map (coverInclusion cover i) ⟨x₀, cover.base_mem i⟩'''
new_def = '''/-- The inclusion-induced homomorphism of one cover member, with the
ambient basepoint codomain made explicit for Lean 4.33 elaboration. -/
def coverFundamentalGroupInclusion {x₀ : X} {ι : Type v}
    (cover : PathConnectedOpenCover x₀ ι) (i : ι) :
    CoverFundamentalGroup cover i →* FundamentalGroup X x₀ :=
  FundamentalGroup.map (coverInclusion cover i) ⟨x₀, cover.base_mem i⟩

/-- The homomorphism from the free product of the fundamental groups of the
cover members to the fundamental group of the ambient space. -/
def vanKampenMap {x₀ : X} {ι : Type v}
    (cover : PathConnectedOpenCover x₀ ι) :
    FreeProduct (fun i => CoverFundamentalGroup cover i) →*
      FundamentalGroup X x₀ :=
  freeProductLift _ (coverFundamentalGroupInclusion cover)'''
if s.count(old_def) != 1:
    raise SystemExit(f'unexpected vanKampenMap definition count: {s.count(old_def)}')
s = s.replace(old_def, new_def)
old_factor = '''  rw [vanKampenMap, freeProductLift, freeProductInclusion,
    Monoid.CoprodI.lift_of]
  change Path.Homotopic.Quotient.map'''
new_factor = '''  rw [vanKampenMap, freeProductLift, freeProductInclusion,
    Monoid.CoprodI.lift_of, coverFundamentalGroupInclusion]
  change Path.Homotopic.Quotient.map'''
if s.count(old_factor) != 1:
    raise SystemExit(f'unexpected vanKampenMap_factor proof block count: {s.count(old_factor)}')
s = s.replace(old_factor, new_factor)
old_relator = '''  simp only [vanKampenRelator, map_mul, map_inv, vanKampenMap,
    freeProductLift, freeProductInclusion, Monoid.CoprodI.lift_of]'''
new_relator = '''  simp only [vanKampenRelator, map_mul, map_inv, vanKampenMap,
    freeProductLift, freeProductInclusion, Monoid.CoprodI.lift_of,
    coverFundamentalGroupInclusion]'''
if s.count(old_relator) != 1:
    raise SystemExit(f'unexpected relator simplification count: {s.count(old_relator)}')
s = s.replace(old_relator, new_relator)
p.write_text(s)

p = Path('HatcherLib/Ch1/VanKampenSweep.lean')
s = p.read_text()
old_h = '''  unfold horizontalBasedEdgeInCell horizontalEdgeLoop
  rw [Path.map_trans, Path.map_trans, ← Path.map_symm,
    grid.vertexConnectorInCell_map, grid.horizontalEdgeInCell_map,
    grid.vertexConnectorInCell_map]
  apply Path.ext
  rfl'''
new_h = '''  unfold horizontalBasedEdgeInCell horizontalEdgeLoop
  rw [Path.map_trans, Path.map_trans, ← Path.map_symm,
    grid.vertexConnectorInCell_map htriple i j i.castSucc s (Or.inl rfl) hjs,
    grid.horizontalEdgeInCell_map i j s hjs,
    grid.vertexConnectorInCell_map htriple i j i.succ s (Or.inr rfl) hjs]
  apply Path.ext
  rfl'''
if s.count(old_h) != 1:
    raise SystemExit(f'unexpected horizontal source proof count: {s.count(old_h)}')
s = s.replace(old_h, new_h)
old_v = '''  unfold verticalBasedEdgeInCell verticalEdgeLoop
  rw [Path.map_trans, Path.map_trans, ← Path.map_symm,
    grid.vertexConnectorInCell_map, grid.verticalEdgeInCell_map,
    grid.vertexConnectorInCell_map]
  apply Path.ext
  rfl'''
new_v = '''  unfold verticalBasedEdgeInCell verticalEdgeLoop
  rw [Path.map_trans, Path.map_trans, ← Path.map_symm,
    grid.vertexConnectorInCell_map htriple i j r j.castSucc hir (Or.inl rfl),
    grid.verticalEdgeInCell_map i j r hir,
    grid.vertexConnectorInCell_map htriple i j r j.succ hir (Or.inr rfl)]
  apply Path.ext
  rfl'''
if s.count(old_v) != 1:
    raise SystemExit(f'unexpected vertical source proof count: {s.count(old_v)}')
s = s.replace(old_v, new_v)
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
  · convert cover.pathConnected false using 1 <;>
      ext x <;> simp only [Set.mem_inter_iff] <;> tauto
  · convert cover.interPathConnected false true using 1 <;>
      ext x <;> simp only [Set.mem_inter_iff] <;> tauto
  · convert cover.interPathConnected false true using 1 <;>
      ext x <;> simp only [Set.mem_inter_iff] <;> tauto
  · convert cover.interPathConnected false true using 1 <;>
      ext x <;> simp only [Set.mem_inter_iff] <;> tauto
  · convert cover.interPathConnected true false using 1 <;>
      ext x <;> simp only [Set.mem_inter_iff] <;> tauto
  · convert cover.interPathConnected true false using 1 <;>
      ext x <;> simp only [Set.mem_inter_iff] <;> tauto
  · convert cover.interPathConnected true false using 1 <;>
      ext x <;> simp only [Set.mem_inter_iff] <;> tauto
  · convert cover.pathConnected true using 1 <;>
      ext x <;> simp only [Set.mem_inter_iff] <;> tauto

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

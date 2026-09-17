#!/usr/bin/env bash
set -euo pipefail

bash diagnostics/run-hatcher-exact-pin.sh
export PATH="$HOME/.elan/bin:$PATH"
cd /tmp/poincare-src/formalized-sources/Hatcher

# Sphere.lean does not use HomotopyApplications declarations for the sphere
# simple-connectivity / punctured-space results audited below.  That import
# transitively pulls in Circle.lean, whose older source has independent
# Lean-4.33 transport migration failures.  Remove only this redundant import
# in the disposable exact-pin replay; theorem bodies remain unchanged.
python3 - <<'PY'
from pathlib import Path
p = Path('HatcherLib/Ch1/Sphere.lean')
s = p.read_text()
old = 'import HatcherLib.Ch1.HomotopyApplications\n'
if s.count(old) != 1:
    raise SystemExit(f'unexpected HomotopyApplications import count: {s.count(old)}')
p.write_text(s.replace(old, '', 1))
PY

if grep -nE '\b(sorry|admit|axiom|unsafe)\b' HatcherLib/Ch1/Sphere.lean; then
  echo 'unexpected proof escape in Sphere.lean' >&2
  exit 1
fi

lake build HatcherLib.Ch1.Sphere

cat > HatcherLib/Ch1/PoincareSphereAudit.lean <<'LEAN'
import HatcherLib.Ch1.Sphere

#print axioms HatcherLib.standardSphereSimplyConnected
#print axioms HatcherLib.sphereSimplyConnected_of_two_le
#print axioms HatcherLib.sphere_piOne_subsingleton_of_two_le
#print axioms HatcherLib.puncturedEuclidean_piOne_subsingleton

example : SimplyConnectedSpace
    (Metric.sphere (0 : EuclideanSpace ℝ (Fin 3)) 1) := by
  simpa using HatcherLib.standardSphereSimplyConnected 0

example (x : ({0}ᶜ : Set (EuclideanSpace ℝ (Fin 3)))) :
    Subsingleton (HatcherLib.PiOne x) := by
  simpa using HatcherLib.puncturedEuclidean_piOne_subsingleton 0 x
LEAN

lake env lean -j1 HatcherLib/Ch1/PoincareSphereAudit.lean

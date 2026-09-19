#!/usr/bin/env bash
set -euo pipefail

ELAN_INSTALLER_COMMIT=464c9d28395000a2a0128e07081e4956d50eced2
ELAN_INSTALLER_SHA256=a620ff1641616222c8d37c54845492004bb84d6877cdbc944dd65c1aa685bf53
LEAN_TOOLCHAIN=leanprover/lean4:v4.33.0
MATHLIB_REV=db584cd6d46c92f209a44c0f1c829460d327499d
HARNESS_ROOT="$(pwd)"

curl --connect-timeout 15 --max-time 240 --proto '=https' --tlsv1.2 -sSf \
  -o /tmp/elan-init.sh \
  "https://raw.githubusercontent.com/leanprover/elan/${ELAN_INSTALLER_COMMIT}/elan-init.sh"
echo "${ELAN_INSTALLER_SHA256}  /tmp/elan-init.sh" | sha256sum --check --strict
sh /tmp/elan-init.sh -y --default-toolchain none
export PATH="$HOME/.elan/bin:$PATH"
elan toolchain install "$LEAN_TOOLCHAIN"

rm -rf /tmp/mathlib-poincare-pushout
git init /tmp/mathlib-poincare-pushout
cd /tmp/mathlib-poincare-pushout
git remote add origin https://github.com/leanprover-community/mathlib4.git
git fetch --depth=1 origin "$MATHLIB_REV"
git checkout --detach FETCH_HEAD

test "$(cat lean-toolchain)" = "$LEAN_TOOLCHAIN"
lake exe cache get

cp "$HARNESS_ROOT/diagnostics/PoincareVanKampenPushoutKernel.lean" .
cp "$HARNESS_ROOT/diagnostics/PoincareULiftPushoutProbe.lean" .
lake env lean PoincareVanKampenPushoutKernel.lean
lake env lean PoincareULiftPushoutProbe.lean

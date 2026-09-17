#!/usr/bin/env bash
set -euo pipefail

bash diagnostics/run-hatcher-row-glue.sh
export PATH="$HOME/.elan/bin:$PATH"
cd /tmp/poincare-src/formalized-sources/Hatcher

cat > HatcherLib/Ch1/PoincareVanKampenRectangleComposition.lean <<'LEAN'
import HatcherLib.Ch1.PoincareVanKampenRows

namespace HatcherLib

noncomputable section

universe u v
variable {X : Type u} [TopologicalSpace X]

namespace VanKampenSweepRow

/-- A finite family of sweep rows indexed in increasing finite order is
composable when every pair of consecutive indices has equivalent shared
frontiers. -/
theorem composable_of_ofFn_adjacent {x₀ : X} {ι : Type v}
    {cover : PathConnectedOpenCover x₀ ι} (n : ℕ)
    (f : Fin n → VanKampenSweepRow cover)
    (hadj : ∀ i j : Fin n, (i : ℕ) + 1 = (j : ℕ) →
      VanKampenWordEquivalent cover (f i).top (f j).bottom) :
    Composable (List.ofFn f) := by
  induction n with
  | zero =>
      simp [List.ofFn_zero, Composable]
  | succ n ih =>
      cases n with
      | zero =>
          simp [List.ofFn_succ, List.ofFn_zero, Composable]
      | succ n =>
          rw [List.ofFn_succ, List.ofFn_succ]
          change
            VanKampenWordEquivalent cover (f 0).top (f 1).bottom ∧
              Composable
                ((List.ofFn fun i : Fin (n + 1) => f i.succ))
          constructor
          · exact hadj 0 1 (by rfl)
          · apply ih
            intro i j hij
            apply hadj i.succ j.succ
            simp only [Fin.val_succ]
            omega

end VanKampenSweepRow

namespace VanKampenSquareGrid

/-- All geometric rows of an adapted grid, ordered from bottom to top. -/
noncomputable def sweepRows {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover) :
    List (VanKampenSweepRow cover) :=
  List.ofFn fun j => grid.sweepRow htriple j

/-- The actual grid rows form a composable bottom-to-top rectangle sweep. -/
theorem sweepRows_composable {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover) :
    VanKampenSweepRow.Composable (grid.sweepRows htriple) := by
  unfold sweepRows
  apply VanKampenSweepRow.composable_of_ofFn_adjacent
  intro i j hij
  apply grid.sweepRow_top_equiv_next_bottom htriple i j
  apply Fin.ext
  exact hij

/-- The complete adapted homotopy grid sweeps its rectangle input frontier to
its rectangle output frontier.  Outer-boundary identification with the two
original factor words is deliberately a separate next lemma. -/
theorem sweepRows_rectangle_equiv {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover) :
    VanKampenWordEquivalent cover
      (VanKampenSweepRow.rectangleInput (grid.sweepRows htriple))
      (VanKampenSweepRow.rectangleOutput (grid.sweepRows htriple)) :=
  VanKampenSweepRow.equivalent_rectangleInput_rectangleOutput
    (grid.sweepRows htriple) (grid.sweepRows_composable htriple)

#print axioms VanKampenSweepRow.composable_of_ofFn_adjacent
#print axioms sweepRows
#print axioms sweepRows_composable
#print axioms sweepRows_rectangle_equiv

end VanKampenSquareGrid

end
end HatcherLib
LEAN

lake build HatcherLib.Ch1.PoincareVanKampenRectangleComposition
lake env lean -j1 HatcherLib/Ch1/PoincareVanKampenRectangleComposition.lean

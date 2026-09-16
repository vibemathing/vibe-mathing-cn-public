#!/usr/bin/env bash
set -euo pipefail

bash diagnostics/run-hatcher-exact-pin.sh
export PATH="$HOME/.elan/bin:$PATH"
cd /tmp/poincare-src/formalized-sources/Hatcher

cat > HatcherLib/Ch1/PoincareVanKampenGlobalGlue.lean <<'LEAN'
import HatcherLib.Ch1.PoincareVanKampenBridge

namespace HatcherLib

noncomputable section

universe u v
variable {X : Type u} [TopologicalSpace X]

namespace VanKampenSquareGrid

/-- Package one concrete grid row as the abstract sweep-row interface used by
`VanKampenSweepRow.equivalent_rectangleInput_rectangleOutput`. -/
noncomputable def sweepRow {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover)
    (j : Fin grid.verticalCells) : VanKampenSweepRow cover := by
  let cells := grid.rowCells htriple j
  refine
    { right := VanKampenSweepCell.firstRightWord cells
      bottom := cells.map (fun c => c.bottom)
      top := cells.map (fun c => c.top)
      left := VanKampenSweepCell.lastLeftWord cells
      step := ?_ }
  rw [← VanKampenSweepCell.inputWord_eq_firstRight_bottoms,
    ← VanKampenSweepCell.outputWord_eq_tops_lastLeft]
  exact grid.rowSweep htriple j

@[simp] theorem sweepRow_bottom {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover)
    (j : Fin grid.verticalCells) :
    (grid.sweepRow htriple j).bottom =
      grid.horizontalFrontierWord htriple j j.castSucc (Or.inl rfl) := by
  simp [sweepRow, rowCells, rowCellsForIndices, horizontalFrontierWord,
    sweepCell, List.map_map, Function.comp_def]

@[simp] theorem sweepRow_top {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover)
    (j : Fin grid.verticalCells) :
    (grid.sweepRow htriple j).top =
      grid.horizontalFrontierWord htriple j j.succ (Or.inr rfl) := by
  simp [sweepRow, rowCells, rowCellsForIndices, horizontalFrontierWord,
    sweepCell, List.map_map, Function.comp_def]

/-- Consecutive concrete rows are composable: their shared horizontal
frontier differs only by the cover labels chosen on the two incident rows. -/
theorem sweepRow_top_equiv_sweepRow_bottom_of_adjacent
    {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover)
    (j k : Fin grid.verticalCells) (hjk : j.succ = k.castSucc) :
    VanKampenWordEquivalent cover
      (grid.sweepRow htriple j).top
      (grid.sweepRow htriple k).bottom := by
  rw [grid.sweepRow_top htriple j, grid.sweepRow_bottom htriple k]
  have h := grid.horizontalFrontierWord_changeRow htriple j k j.succ
    (Or.inr rfl) (Or.inl hjk)
  simpa [hjk] using h

#print axioms sweepRow
#print axioms sweepRow_bottom
#print axioms sweepRow_top
#print axioms sweepRow_top_equiv_sweepRow_bottom_of_adjacent

end VanKampenSquareGrid

end

end HatcherLib
LEAN

lake build HatcherLib.Ch1.PoincareVanKampenGlobalGlue
lake env lean -j1 HatcherLib/Ch1/PoincareVanKampenGlobalGlue.lean

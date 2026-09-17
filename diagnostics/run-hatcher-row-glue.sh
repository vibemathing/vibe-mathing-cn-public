#!/usr/bin/env bash
set -euo pipefail

bash diagnostics/run-hatcher-factor-corollary.sh
export PATH="$HOME/.elan/bin:$PATH"
cd /tmp/poincare-src/formalized-sources/Hatcher

cat > HatcherLib/Ch1/PoincareVanKampenRows.lean <<'LEAN'
import HatcherLib.Ch1.PoincareVanKampenCorollary

namespace HatcherLib

noncomputable section

universe u v
variable {X : Type u} [TopologicalSpace X]

namespace VanKampenSquareGrid

/-- Package one actual adapted-grid row as the abstract rectangle-sweep row.
The bottom and top words are the geometric horizontal frontiers; the right
and left words are the outer vertical-edge factors exposed by the row sweep. -/
noncomputable def sweepRow {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover)
    (j : Fin grid.verticalCells) : VanKampenSweepRow cover where
  right := VanKampenSweepCell.firstRightWord (grid.rowCells htriple j)
  bottom := grid.horizontalFrontierWord htriple j j.castSucc (Or.inl rfl)
  top := grid.horizontalFrontierWord htriple j j.succ (Or.inr rfl)
  left := VanKampenSweepCell.lastLeftWord (grid.rowCells htriple j)
  step := by
    have h := grid.rowSweep htriple j
    rw [VanKampenSweepCell.inputWord_eq_firstRight_bottoms,
      VanKampenSweepCell.outputWord_eq_tops_lastLeft] at h
    simpa [horizontalFrontierWord, rowCells, rowCellsForIndices, sweepCell]
      using h

/-- Consecutive actual grid rows have equivalent words on their common
horizontal frontier.  The only change is which incident row supplies the
cover labels of those same geometric edges. -/
theorem sweepRow_top_equiv_next_bottom {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover)
    (j k : Fin grid.verticalCells) (hjk : j.succ = k.castSucc) :
    VanKampenWordEquivalent cover
      (grid.sweepRow htriple j).top
      (grid.sweepRow htriple k).bottom := by
  have h := grid.horizontalFrontierWord_changeRow htriple
    j k j.succ (Or.inr rfl) (Or.inl hjk)
  simpa [sweepRow] using h

#print axioms sweepRow
#print axioms sweepRow_top_equiv_next_bottom

end VanKampenSquareGrid

end
end HatcherLib
LEAN

lake build HatcherLib.Ch1.PoincareVanKampenRows
lake env lean -j1 HatcherLib/Ch1/PoincareVanKampenRows.lean

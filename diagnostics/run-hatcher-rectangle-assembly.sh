#!/usr/bin/env bash
set -euo pipefail

bash diagnostics/run-hatcher-factor-corollary.sh
export PATH="$HOME/.elan/bin:$PATH"
cd /tmp/poincare-src/formalized-sources/Hatcher
cat > HatcherLib/Ch1/PoincareVanKampenRectangle.lean <<'LEAN'
import HatcherLib.Ch1.PoincareVanKampenCorollary

namespace HatcherLib

noncomputable section

universe u v
variable {X : Type u} [TopologicalSpace X]

namespace VanKampenSquareGrid

/-- Package one geometric grid row as the abstract sweep-row interface. -/
noncomputable def sweepRow {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover)
    (j : Fin grid.verticalCells) : VanKampenSweepRow cover where
  right := VanKampenSweepCell.firstRightWord (grid.rowCells htriple j)
  bottom := (grid.rowCells htriple j).map (fun c => c.bottom)
  top := (grid.rowCells htriple j).map (fun c => c.top)
  left := VanKampenSweepCell.lastLeftWord (grid.rowCells htriple j)
  step := by
    rw [← VanKampenSweepCell.inputWord_eq_firstRight_bottoms,
      ← VanKampenSweepCell.outputWord_eq_tops_lastLeft]
    exact grid.rowSweep htriple j

/-- Consecutive geometric rows have equivalent words on their shared
horizontal frontier. -/
theorem sweepRow_top_equiv_next_bottom {x₀ : X} {ι : Type v}
    {p q : Loop x₀} {cover : PathConnectedOpenCover x₀ ι}
    {F : Path.Homotopy p q} (grid : VanKampenSquareGrid cover F)
    (htriple : VanKampenTripleIntersectionsPathConnected cover)
    (j k : Fin grid.verticalCells) (hjk : j.succ = k.castSucc) :
    VanKampenWordEquivalent cover
      (grid.sweepRow htriple j).top
      (grid.sweepRow htriple k).bottom := by
  change VanKampenWordEquivalent cover
    ((grid.rowCells htriple j).map (fun c => c.top))
    ((grid.rowCells htriple k).map (fun c => c.bottom))
  unfold rowCells rowCellsForIndices
  simp only [List.map_map]
  apply vanKampenWordEquivalent_map_singletons (descendingFin grid.horizontalCells)
  intro i hi
  have hchange := grid.horizontalEdgeFactor_changeCell htriple
    i j k j.succ (Or.inr rfl) (Or.inl hjk) [] []
  simpa [sweepCell, Function.comp_def] using hchange

#print axioms sweepRow
#print axioms sweepRow_top_equiv_next_bottom

end VanKampenSquareGrid

end

end HatcherLib
LEAN

lake build HatcherLib.Ch1.PoincareVanKampenRectangle
lake env lean -j1 HatcherLib/Ch1/PoincareVanKampenRectangle.lean

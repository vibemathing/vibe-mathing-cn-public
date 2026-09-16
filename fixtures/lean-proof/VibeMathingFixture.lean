import Mathlib.Data.Nat.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Topology.MetricSpace.Isometry

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Exact-pin probe for the Alexander radial extension used by the remaining
`S³ # S³ ≃ₜ S³` Poincare endgame obligation.

The construction is adapted from the no-sorry twisted-sphere source in
`primaryhosting/brockian-mathematics@ed95b048...`, specialized to finite
real Euclidean spaces and rebuilt only from Mathlib APIs.
-/

namespace ClayPoincareAlexander

open Metric
open scoped Classical

noncomputable section

abbrev E (n : ℕ) := EuclideanSpace ℝ (Fin n)
abbrev Sph (n : ℕ) := sphere (0 : E n) 1

/-- Radial projection of a nonzero Euclidean vector to the unit sphere. -/
noncomputable def normalizePt {n : ℕ} {x : E n} (hx : x ≠ 0) : Sph n :=
  ⟨‖x‖⁻¹ • x, by
    simp only [mem_sphere_zero_iff_norm, norm_smul, norm_inv, norm_norm]
    field_simp⟩

@[simp] lemma coe_normalizePt {n : ℕ} {x : E n} (hx : x ≠ 0) :
    (normalizePt hx : E n) = ‖x‖⁻¹ • x := rfl

/-- The cone/radial extension of a self-map of the unit sphere. -/
noncomputable def coneMap {n : ℕ} (f : Sph n → Sph n) (x : E n) : E n :=
  if h : x = 0 then 0 else ‖x‖ • (f (normalizePt h) : E n)

@[simp] lemma coneMap_zero {n : ℕ} (f : Sph n → Sph n) : coneMap f 0 = 0 := by
  simp [coneMap]

lemma coneMap_of_ne_zero {n : ℕ} (f : Sph n → Sph n) {x : E n} (hx : x ≠ 0) :
    coneMap f x = ‖x‖ • (f (normalizePt hx) : E n) := by
  rw [coneMap, dif_neg hx]

@[simp] lemma norm_coneMap {n : ℕ} (f : Sph n → Sph n) (x : E n) :
    ‖coneMap f x‖ = ‖x‖ := by
  rcases eq_or_ne x 0 with rfl | hx
  · simp
  · rw [coneMap_of_ne_zero f hx, norm_smul, norm_coe_unitSphere]
    simp

lemma coneMap_coe_sphere {n : ℕ} (f : Sph n → Sph n) (x : Sph n) :
    coneMap f (x : E n) = f x := by
  have hx : (x : E n) ≠ 0 := coe_unitSphere_ne_zero x
  have hn : ‖(x : E n)‖ = 1 := norm_coe_unitSphere x
  have hpt : normalizePt hx = x := by
    apply Subtype.ext
    simp [hn]
  rw [coneMap_of_ne_zero f hx, hpt, hn, one_smul]

/-- Radial projection as a map on the open nonzero subspace. -/
noncomputable def radialProj {n : ℕ} : {x : E n // x ≠ 0} → Sph n :=
  fun p => normalizePt p.2

lemma continuous_radialProj {n : ℕ} : Continuous (radialProj (n := n)) := by
  apply Continuous.subtype_mk
  have h1 : Continuous fun p : {x : E n // x ≠ 0} => ‖(p : E n)‖ :=
    continuous_norm.comp continuous_subtype_val
  exact (h1.inv₀ fun p => norm_ne_zero_iff.mpr p.2).smul continuous_subtype_val

lemma continuous_coneMap {n : ℕ} {f : Sph n → Sph n} (hf : Continuous f) :
    Continuous (coneMap f) := by
  rw [continuous_iff_continuousAt]
  intro x
  rcases eq_or_ne x 0 with rfl | hx
  · rw [ContinuousAt, coneMap_zero]
    refine squeeze_zero_norm (fun y => le_of_eq (norm_coneMap f y)) ?_
    simpa using (continuous_norm (E := E n)).tendsto' 0 0 (by simp)
  · have hopen : IsOpen {y : E n | y ≠ 0} := isOpen_ne
    have hcont : ContinuousOn (coneMap f) {y : E n | y ≠ 0} := by
      rw [continuousOn_iff_continuous_restrict]
      have hrestr : Set.restrict {y : E n | y ≠ 0} (coneMap f)
          = fun p : {y : E n // y ∈ {y : E n | y ≠ 0}} =>
            ‖(p : E n)‖ • (f (radialProj ⟨p.1, p.2⟩) : E n) := by
        funext p
        exact coneMap_of_ne_zero f p.2
      rw [hrestr]
      exact (continuous_norm.comp continuous_subtype_val).smul
        (continuous_subtype_val.comp (hf.comp (continuous_radialProj.comp
          (Continuous.subtype_mk continuous_subtype_val _))))
    exact hcont.continuousAt (hopen.mem_nhds hx)

lemma coneMap_comp_coneMap {n : ℕ} (f g : Sph n → Sph n)
    (hgf : ∀ y, g (f y) = y) (x : E n) :
    coneMap g (coneMap f x) = x := by
  rcases eq_or_ne x 0 with rfl | hx
  · simp
  · have hnx : ‖x‖ ≠ 0 := norm_ne_zero_iff.mpr hx
    have hFx : coneMap f x ≠ 0 := by
      intro h
      rw [← norm_eq_zero, norm_coneMap] at h
      exact hnx h
    rw [coneMap_of_ne_zero g hFx]
    have hpt : normalizePt hFx = f (normalizePt hx) := by
      apply Subtype.ext
      rw [coe_normalizePt, norm_coneMap, coneMap_of_ne_zero f hx, smul_smul,
        inv_mul_cancel₀ hnx, one_smul]
    rw [hpt, hgf, norm_coneMap, coe_normalizePt, smul_smul,
      mul_inv_cancel₀ hnx, one_smul]

/-- Alexander trick: every unit-sphere homeomorphism extends to a
norm-preserving homeomorphism of the ambient Euclidean space. -/
noncomputable def coneHomeomorph {n : ℕ} (f : Sph n ≃ₜ Sph n) : E n ≃ₜ E n where
  toFun := coneMap f
  invFun := coneMap f.symm
  left_inv x := coneMap_comp_coneMap _ _ (fun y => f.symm_apply_apply y) x
  right_inv x := coneMap_comp_coneMap _ _ (fun y => f.apply_symm_apply y) x
  continuous_toFun := continuous_coneMap f.continuous
  continuous_invFun := continuous_coneMap f.symm.continuous

@[simp] lemma norm_coneHomeomorph {n : ℕ} (f : Sph n ≃ₜ Sph n) (x : E n) :
    ‖coneHomeomorph f x‖ = ‖x‖ := norm_coneMap f x

lemma coneHomeomorph_coe_sphere {n : ℕ} (f : Sph n ≃ₜ Sph n) (x : Sph n) :
    coneHomeomorph f (x : E n) = f x := coneMap_coe_sphere _ x

/-- The exact `S²` case needed for 3-ball gluings. -/
theorem sphereTwo_homeomorph_extends
    (f : Sph 3 ≃ₜ Sph 3) :
    ∃ F : E 3 ≃ₜ E 3,
      (∀ x : Sph 3, F (x : E 3) = (f x : E 3)) ∧
      ∀ x : E 3, ‖F x‖ = ‖x‖ :=
  ⟨coneHomeomorph f, coneHomeomorph_coe_sphere f, norm_coneHomeomorph f⟩

end

end ClayPoincareAlexander

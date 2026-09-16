import Mathlib.Data.Nat.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Topology.MetricSpace.Isometry
import Mathlib.Topology.Constructions
import Mathlib.Topology.Homeomorph.Lemmas

namespace VibeMathingFixture

theorem two_add_two : (2 : ℕ) + 2 = 4 := by
  rfl

#print axioms two_add_two

end VibeMathingFixture

/-!
Exact-pin replay of the Alexander radial extension and twisted-sphere theorem
needed by the remaining `S³ # S³ ≃ₜ S³` Poincare endgame obligation.

The construction is adapted from the no-sorry source in
`primaryhosting/brockian-mathematics@ed95b048...`, migrated from Mathlib 4.32
to the target Lean 4.33.0 / Mathlib `db584cd6...` APIs.
-/

namespace ClayPoincareAlexander

open Metric
open scoped Classical

noncomputable section

abbrev E (n : ℕ) := EuclideanSpace ℝ (Fin n)
abbrev Sph (n : ℕ) := sphere (0 : E n) 1
abbrev Dsk (n : ℕ) := closedBall (0 : E n) 1

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
  · have hfunit : ‖(f (normalizePt hx) : E n)‖ = 1 :=
      mem_sphere_zero_iff_norm.mp (f (normalizePt hx)).property
    rw [coneMap_of_ne_zero f hx, norm_smul, hfunit]
    simp

lemma coneMap_coe_sphere {n : ℕ} (f : Sph n → Sph n) (x : Sph n) :
    coneMap f (x : E n) = f x := by
  have hn : ‖(x : E n)‖ = 1 := mem_sphere_zero_iff_norm.mp x.property
  have hx : (x : E n) ≠ 0 := by
    intro hx0
    rw [hx0, norm_zero] at hn
    norm_num at hn
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
      rw [continuousOn_iff_continuous_domRestrict]
      have hrestr : ({y : E n | y ≠ 0}.domRestrict (coneMap f))
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

lemma norm_coe_dsk_le {n : ℕ} (x : Dsk n) : ‖(x : E n)‖ ≤ 1 :=
  mem_closedBall_zero_iff.mp x.2

/-- The boundary sphere sits inside the closed disk. -/
def sphereToDisk {n : ℕ} (x : Sph n) : Dsk n :=
  ⟨(x : E n), by
    rw [mem_closedBall_zero_iff]
    exact le_of_eq (mem_sphere_zero_iff_norm.mp x.property)⟩

/-- The generating boundary identification for a twisted double of a disk. -/
inductive GlueRel {n : ℕ} (f : Sph n ≃ₜ Sph n) : Dsk n ⊕ Dsk n → Dsk n ⊕ Dsk n → Prop
  | intro (x : Sph n) : GlueRel f (Sum.inl (sphereToDisk x)) (Sum.inr (sphereToDisk (f x)))

/-- Two closed `n`-disks glued along their unit-sphere boundaries by `f`. -/
def TwistedSphere {n : ℕ} (f : Sph n ≃ₜ Sph n) : Type := Quot (GlueRel f)

instance {n : ℕ} (f : Sph n ≃ₜ Sph n) : TopologicalSpace (TwistedSphere f) :=
  inferInstanceAs (TopologicalSpace (Quot _))

instance {n : ℕ} (f : Sph n ≃ₜ Sph n) : CompactSpace (TwistedSphere f) :=
  inferInstanceAs (CompactSpace (Quot _))

def TwistedSphere.mk {n : ℕ} (f : Sph n ≃ₜ Sph n) (p : Dsk n ⊕ Dsk n) : TwistedSphere f :=
  Quot.mk _ p

lemma TwistedSphere.continuous_mk {n : ℕ} (f : Sph n ≃ₜ Sph n) :
    Continuous (TwistedSphere.mk f) := continuous_quot_mk

lemma TwistedSphere.sound {n : ℕ} (f : Sph n ≃ₜ Sph n) (x : Sph n) :
    TwistedSphere.mk f (Sum.inl (sphereToDisk x)) =
      TwistedSphere.mk f (Sum.inr (sphereToDisk (f x))) :=
  Quot.sound (GlueRel.intro x)

/-- Alexander extension restricted to the closed disk. -/
noncomputable def diskMap {n : ℕ} (f : Sph n ≃ₜ Sph n) (y : Dsk n) : Dsk n :=
  ⟨coneHomeomorph f (y : E n), by
    rw [mem_closedBall_zero_iff, norm_coneHomeomorph]
    exact norm_coe_dsk_le y⟩

lemma continuous_diskMap {n : ℕ} (f : Sph n ≃ₜ Sph n) : Continuous (diskMap f) :=
  Continuous.subtype_mk ((coneHomeomorph f).continuous.comp continuous_subtype_val) _

lemma diskMap_symm_diskMap {n : ℕ} (f : Sph n ≃ₜ Sph n) (y : Dsk n) :
    diskMap f.symm (diskMap f y) = y := by
  apply Subtype.ext
  exact coneMap_comp_coneMap _ _ (fun z => f.symm_apply_apply z) _

lemma diskMap_diskMap_symm {n : ℕ} (f : Sph n ≃ₜ Sph n) (y : Dsk n) :
    diskMap f (diskMap f.symm y) = y := by
  apply Subtype.ext
  exact coneMap_comp_coneMap _ _ (fun z => f.apply_symm_apply z) _

lemma diskMap_sphereToDisk {n : ℕ} (f : Sph n ≃ₜ Sph n) (x : Sph n) :
    diskMap f (sphereToDisk x) = sphereToDisk (f x) := by
  apply Subtype.ext
  exact coneHomeomorph_coe_sphere f x

abbrev sphereId (n : ℕ) : Sph n ≃ₜ Sph n := Homeomorph.refl _

noncomputable def untwistInv {n : ℕ} (f : Sph n ≃ₜ Sph n) :
    TwistedSphere (sphereId n) → TwistedSphere f := by
  refine Quot.lift (fun p => TwistedSphere.mk f (Sum.map id (diskMap f) p)) ?_
  rintro _ _ ⟨x⟩
  simpa [Sum.map, diskMap_sphereToDisk f x] using TwistedSphere.sound f x

noncomputable def untwist {n : ℕ} (f : Sph n ≃ₜ Sph n) :
    TwistedSphere f → TwistedSphere (sphereId n) := by
  refine Quot.lift (fun p => TwistedSphere.mk (sphereId n) (Sum.map id (diskMap f.symm) p)) ?_
  rintro _ _ ⟨x⟩
  have h : diskMap f.symm (sphereToDisk (f x)) = sphereToDisk x := by
    rw [diskMap_sphereToDisk f.symm (f x)]
    simp
  simpa [Sum.map, h] using TwistedSphere.sound (sphereId n) x

/-- Alexander untwisting of an arbitrary boundary gluing. -/
noncomputable def twistedSphereHomeomorphUntwisted {n : ℕ} (f : Sph n ≃ₜ Sph n) :
    TwistedSphere f ≃ₜ TwistedSphere (sphereId n) where
  toFun := untwist f
  invFun := untwistInv f
  left_inv := by
    intro z
    induction z using Quot.ind with
    | mk p =>
      cases p with
      | inl x => rfl
      | inr y =>
        show TwistedSphere.mk f (Sum.inr (diskMap f (diskMap f.symm y))) = _
        rw [diskMap_diskMap_symm]
        rfl
  right_inv := by
    intro z
    induction z using Quot.ind with
    | mk p =>
      cases p with
      | inl x => rfl
      | inr y =>
        show TwistedSphere.mk (sphereId n) (Sum.inr (diskMap f.symm (diskMap f y))) = _
        rw [diskMap_symm_diskMap]
        rfl
  continuous_toFun := by
    apply continuous_quot_lift
    exact (TwistedSphere.continuous_mk _).comp
      (continuous_id.sumMap (continuous_diskMap f.symm))
  continuous_invFun := by
    apply continuous_quot_lift
    exact (TwistedSphere.continuous_mk _).comp
      (continuous_id.sumMap (continuous_diskMap f))

/-- Append a last coordinate to a Euclidean vector. -/
noncomputable def snocLp {n : ℕ} (x : E n) (t : ℝ) : E (n + 1) :=
  WithLp.toLp 2 (Fin.snoc (WithLp.ofLp x) t)

lemma norm_snocLp_sq {n : ℕ} (x : E n) (t : ℝ) :
    ‖snocLp x t‖ ^ 2 = ‖x‖ ^ 2 + t ^ 2 := by
  simp only [snocLp, EuclideanSpace.norm_eq, Fin.sum_univ_castSucc,
    Fin.snoc_castSucc, Fin.snoc_last, Real.norm_eq_abs, sq_abs]
  rw [Real.sq_sqrt (by positivity), Real.sq_sqrt (by positivity)]

lemma snocLp_apply_castSucc {n : ℕ} (x : E n) (t : ℝ) (i : Fin n) :
    (WithLp.ofLp (snocLp x t)) i.castSucc = (WithLp.ofLp x) i := by
  simp [snocLp]

lemma snocLp_apply_last {n : ℕ} (x : E n) (t : ℝ) :
    (WithLp.ofLp (snocLp x t)) (Fin.last n) = t := by
  simp [snocLp]

lemma snocLp_injective {n : ℕ} {x y : E n} {t s : ℝ}
    (h : snocLp x t = snocLp y s) : x = y ∧ t = s := by
  constructor
  · ext i
    have h' := congrArg (fun v => (WithLp.ofLp v) i.castSucc) h
    simpa [snocLp_apply_castSucc] using h'
  · have h' := congrArg (fun v => (WithLp.ofLp v) (Fin.last n)) h
    simpa [snocLp_apply_last] using h'

lemma exists_snocLp {n : ℕ} (v : E (n + 1)) : ∃ (x : E n) (t : ℝ), v = snocLp x t := by
  refine ⟨WithLp.toLp 2 (Fin.init (WithLp.ofLp v)), (WithLp.ofLp v) (Fin.last n), ?_⟩
  apply WithLp.ofLp_injective
  simp [snocLp, Fin.snoc_init_self]

/-- Upper/lower hemisphere maps from the closed disk. -/
noncomputable def hemisphere {n : ℕ} (e : ℝ) (he : e ^ 2 = 1) (x : Dsk n) : Sph (n + 1) :=
  ⟨snocLp (x : E n) (e * Real.sqrt (1 - ‖(x : E n)‖ ^ 2)), by
    have hx : ‖(x : E n)‖ ^ 2 ≤ 1 := by
      have h1 := norm_coe_dsk_le x
      nlinarith [norm_nonneg (x : E n)]
    rw [mem_sphere_zero_iff_norm]
    have hsq : ‖snocLp (x : E n) (e * Real.sqrt (1 - ‖(x : E n)‖ ^ 2))‖ ^ 2 = 1 := by
      rw [norm_snocLp_sq, mul_pow, he, one_mul, Real.sq_sqrt (by linarith)]
      ring
    nlinarith [norm_nonneg (snocLp (x : E n)
      (e * Real.sqrt (1 - ‖(x : E n)‖ ^ 2)))]⟩

lemma continuous_snocLp {X : Type*} [TopologicalSpace X] {n : ℕ}
    {g : X → E n} {t : X → ℝ} (hg : Continuous g) (ht : Continuous t) :
    Continuous fun s => snocLp (g s) (t s) := by
  refine (PiLp.continuous_toLp 2 _).comp ?_
  apply continuous_pi
  intro i
  refine Fin.lastCases ?_ ?_ i
  · simpa using ht
  · intro j
    simpa using (continuous_apply j).comp ((PiLp.continuous_ofLp 2 _).comp hg)

lemma continuous_hemisphere {n : ℕ} (e : ℝ) (he : e ^ 2 = 1) :
    Continuous (hemisphere (n := n) e he) := by
  apply Continuous.subtype_mk
  exact continuous_snocLp continuous_subtype_val
    (continuous_const.mul (Real.continuous_sqrt.comp
      (continuous_const.sub ((continuous_norm.comp continuous_subtype_val).pow 2))))

noncomputable def doubleToSphere {n : ℕ} : Dsk n ⊕ Dsk n → Sph (n + 1) :=
  Sum.elim (hemisphere 1 (by norm_num)) (hemisphere (-1) (by norm_num))

lemma continuous_doubleToSphere {n : ℕ} : Continuous (doubleToSphere (n := n)) :=
  Continuous.sumElim (continuous_hemisphere _ _) (continuous_hemisphere _ _)

lemma hemisphere_of_norm_one {n : ℕ} (e : ℝ) (he : e ^ 2 = 1) (x : Dsk n)
    (hx : ‖(x : E n)‖ = 1) :
    (hemisphere e he x : E (n + 1)) = snocLp (x : E n) 0 := by
  show snocLp _ _ = _
  rw [hx]
  norm_num

lemma doubleToSphere_glue {n : ℕ} (a b : Dsk n ⊕ Dsk n)
    (h : GlueRel (sphereId n) a b) : doubleToSphere a = doubleToSphere b := by
  cases h with
  | intro x =>
    apply Subtype.ext
    show (hemisphere 1 (by norm_num) (sphereToDisk x) : E (n + 1)) =
      (hemisphere (-1) (by norm_num) (sphereToDisk (x : Sph n)) : E (n + 1))
    have hx : ‖((sphereToDisk x : Dsk n) : E n)‖ = 1 :=
      mem_sphere_zero_iff_norm.mp x.property
    rw [hemisphere_of_norm_one _ _ _ hx, hemisphere_of_norm_one _ _ _ hx]

noncomputable def untwistedToSphere {n : ℕ} :
    TwistedSphere (sphereId n) → Sph (n + 1) :=
  Quot.lift doubleToSphere doubleToSphere_glue

lemma untwistedToSphere_surjective {n : ℕ} :
    Function.Surjective (untwistedToSphere (n := n)) := by
  intro v
  obtain ⟨x, t, hxt⟩ := exists_snocLp (v : E (n + 1))
  have hv : ‖(v : E (n + 1))‖ = 1 := mem_sphere_zero_iff_norm.mp v.property
  have hsum : ‖x‖ ^ 2 + t ^ 2 = 1 := by
    rw [← norm_snocLp_sq, ← hxt, hv]
    norm_num
  have hxle : ‖x‖ ≤ 1 := by nlinarith [norm_nonneg x, sq_nonneg t]
  have hsq : Real.sqrt (1 - ‖x‖ ^ 2) = |t| := by
    have h : (1 : ℝ) - ‖x‖ ^ 2 = t ^ 2 := by linarith
    rw [h, Real.sqrt_sq_eq_abs]
  set d : Dsk n := ⟨x, mem_closedBall_zero_iff.mpr hxle⟩ with hd
  rcases le_total 0 t with ht | ht
  · refine ⟨Quot.mk _ (Sum.inl d), ?_⟩
    apply Subtype.ext
    show snocLp x (1 * Real.sqrt (1 - ‖x‖ ^ 2)) = _
    rw [one_mul, hsq, abs_of_nonneg ht, ← hxt]
  · refine ⟨Quot.mk _ (Sum.inr d), ?_⟩
    apply Subtype.ext
    show snocLp x (-1 * Real.sqrt (1 - ‖x‖ ^ 2)) = _
    rw [hsq, abs_of_nonpos ht, hxt]
    ring_nf

lemma norm_eq_one_of_sqrt_eq_neg {n : ℕ} {x : Dsk n}
    (h : Real.sqrt (1 - ‖(x : E n)‖ ^ 2) = -Real.sqrt (1 - ‖(x : E n)‖ ^ 2)) :
    ‖(x : E n)‖ = 1 := by
  have hz : Real.sqrt (1 - ‖(x : E n)‖ ^ 2) = 0 := by linarith
  have hle : 1 - ‖(x : E n)‖ ^ 2 ≤ 0 := Real.sqrt_eq_zero'.mp hz
  have h1 := norm_coe_dsk_le x
  nlinarith [norm_nonneg (x : E n)]

lemma doubleToSphere_inj_aux {n : ℕ} (a b : Dsk n ⊕ Dsk n)
    (h : doubleToSphere a = doubleToSphere b) :
    Quot.mk (GlueRel (sphereId n)) a = Quot.mk (GlueRel (sphereId n)) b := by
  have key : ∀ (u v : Dsk n) (e₁ e₂ : ℝ) (h₁ : e₁ ^ 2 = 1) (h₂ : e₂ ^ 2 = 1),
      (hemisphere e₁ h₁ u : E (n + 1)) = (hemisphere e₂ h₂ v : E (n + 1)) →
      (u : E n) = (v : E n) ∧
        e₁ * Real.sqrt (1 - ‖(u : E n)‖ ^ 2) =
          e₂ * Real.sqrt (1 - ‖(v : E n)‖ ^ 2) := by
    intro u v e₁ e₂ h₁ h₂ huv
    exact snocLp_injective huv
  cases a with
  | inl u =>
    cases b with
    | inl v =>
      obtain ⟨h1, -⟩ := key u v 1 1 (by norm_num) (by norm_num) (congrArg Subtype.val h)
      rw [Subtype.ext h1]
    | inr v =>
      obtain ⟨h1, h2⟩ := key u v 1 (-1) (by norm_num) (by norm_num) (congrArg Subtype.val h)
      rw [one_mul, neg_one_mul, ← h1] at h2
      have hnorm : ‖(u : E n)‖ = 1 := norm_eq_one_of_sqrt_eq_neg h2
      have hu : u = sphereToDisk ⟨(u : E n), mem_sphere_zero_iff_norm.mpr hnorm⟩ := rfl
      have hv : v = sphereToDisk ⟨(u : E n), mem_sphere_zero_iff_norm.mpr hnorm⟩ :=
        Subtype.ext h1.symm
      rw [hu, hv]
      exact TwistedSphere.sound (sphereId n) _
  | inr u =>
    cases b with
    | inl v =>
      obtain ⟨h1, h2⟩ := key u v (-1) 1 (by norm_num) (by norm_num) (congrArg Subtype.val h)
      rw [one_mul, neg_one_mul, ← h1] at h2
      have hnorm : ‖(u : E n)‖ = 1 := norm_eq_one_of_sqrt_eq_neg (by linarith)
      have hu : u = sphereToDisk ⟨(u : E n), mem_sphere_zero_iff_norm.mpr hnorm⟩ := rfl
      have hv : v = sphereToDisk ⟨(u : E n), mem_sphere_zero_iff_norm.mpr hnorm⟩ :=
        Subtype.ext h1.symm
      rw [hu, hv]
      exact (TwistedSphere.sound (sphereId n) _).symm
    | inr v =>
      obtain ⟨h1, -⟩ := key u v (-1) (-1) (by norm_num) (by norm_num) (congrArg Subtype.val h)
      rw [Subtype.ext h1]

lemma untwistedToSphere_injective {n : ℕ} : Function.Injective (untwistedToSphere (n := n)) := by
  intro z w h
  induction z using Quot.ind with
  | mk a =>
    induction w using Quot.ind with
    | mk b => exact doubleToSphere_inj_aux a b h

/-- The untwisted double of an `n`-disk is the standard `n`-sphere. -/
noncomputable def untwistedHomeomorphSphere (n : ℕ) :
    TwistedSphere (sphereId n) ≃ₜ Sph (n + 1) :=
  Continuous.homeoOfEquivCompactToT2
    (f := Equiv.ofBijective untwistedToSphere
      ⟨untwistedToSphere_injective, untwistedToSphere_surjective⟩)
    (continuous_quot_lift _ continuous_doubleToSphere)

/-- Every twisted double of the closed `n`-disk is homeomorphic to the standard sphere. -/
noncomputable def twistedSphereHomeomorphSphere {n : ℕ} (f : Sph n ≃ₜ Sph n) :
    TwistedSphere f ≃ₜ Sph (n + 1) :=
  (twistedSphereHomeomorphUntwisted f).trans (untwistedHomeomorphSphere n)

theorem nonempty_twistedSphere_homeomorph_sphere {n : ℕ} (f : Sph n ≃ₜ Sph n) :
    Nonempty (TwistedSphere f ≃ₜ Sph (n + 1)) :=
  ⟨twistedSphereHomeomorphSphere f⟩

/-- The dimension-three instance needed by the Poincare connected-sum endgame. -/
theorem twistedThreeBallDouble_homeomorph_sphereThree (f : Sph 3 ≃ₜ Sph 3) :
    Nonempty (TwistedSphere f ≃ₜ Sph 4) :=
  nonempty_twistedSphere_homeomorph_sphere f

end

end ClayPoincareAlexander

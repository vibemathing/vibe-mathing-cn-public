import PoincareTwoOpenCoverKernel
import PoincareTwoOpenPushoutCocone

open CategoryTheory CategoryTheory.Limits
open TopologicalSpace

set_option backward.isDefEq.respectTransparency false

universe u

variable {X : Type u} [TopologicalSpace X]

/-- Bundle the fundamental groupoid inclusion associated to an inclusion of opens
as a morphism in `Grpd`. -/
abbrev opensFundamentalGroupoidHom {A B : Opens X} (h : A ≤ B) :
    Grpd.of (FundamentalGroupoid A) ⟶ Grpd.of (FundamentalGroupoid B) :=
  opensFundamentalGroupoidInclusion h

/-- Fundamental-groupoid inclusions compose exactly as inclusions of opens. -/
theorem opensFundamentalGroupoidHom_comp
    {A B C : Opens X} (hAB : A ≤ B) (hBC : B ≤ C) :
    opensFundamentalGroupoidHom hAB ≫
        opensFundamentalGroupoidHom hBC =
      opensFundamentalGroupoidHom (hAB.trans hBC) := by
  rw [Grpd.comp_eq_comp]
  rw [← FundamentalGroupoid.map_comp]
  congr 1
  ext x
  rfl

/-- Inclusion of an open into itself induces the identity fundamental-groupoid
functor. -/
theorem opensFundamentalGroupoidHom_refl (A : Opens X) :
    opensFundamentalGroupoidHom (show A ≤ A from le_rfl) =
      𝟙 (Grpd.of (FundamentalGroupoid A)) := by
  rw [Grpd.id_eq_id]
  change FundamentalGroupoid.map
      (opensContinuousInclusion (show A ≤ A from le_rfl)) = 𝟭 _
  have h :
      opensContinuousInclusion (show A ≤ A from le_rfl) =
        ContinuousMap.id A := by
    ext x
    rfl
  rw [h, FundamentalGroupoid.map_id]

/-- The exact intersection-closed Van Kampen diagram for all opens subordinate
to one side of a two-open cover. -/
abbrev subordinateTwoCoverDiagram (U V : Opens X) :=
  (((Subtype.mono_coe
      (fun O : Opens X => O ∈ subordinateTwoCover U V)).functor) ⋙
    Opens.toTopCat (TopCat.of X) ⋙
    FundamentalGroupoid.fundamentalGroupoidFunctor)

/-- The map in the subordinate-cover diagram is the fundamental-groupoid map
of the corresponding inclusion of opens. -/
theorem subordinateTwoCoverDiagram_map
    (U V : Opens X)
    {A B : {O : Opens X // O ∈ subordinateTwoCover U V}}
    (f : A ⟶ B) :
    (subordinateTwoCoverDiagram U V).map f =
      opensFundamentalGroupoidHom f.le := by
  rfl

/-- Extend a pushout cocone on the span
`U ∩ V → U, U ∩ V → V` to the whole intersection-closed family of
opens subordinate to `U` or `V`.  We deterministically prefer the
`U` side whenever an open lies in both sides. -/
noncomputable def subordinateTwoCoverCoconeOfPushout
    (U V : Opens X)
    (c : PushoutCocone
      (show Grpd.of (FundamentalGroupoid (U ⊓ V)) ⟶
          Grpd.of (FundamentalGroupoid U) from overlapLeftFunctor U V)
      (show Grpd.of (FundamentalGroupoid (U ⊓ V)) ⟶
          Grpd.of (FundamentalGroupoid V) from overlapRightFunctor U V)) :
    Cocone (subordinateTwoCoverDiagram U V) where
  pt := c.pt
  ι :=
    { app := fun O => by
        classical
        by_cases hOU : O.1 ≤ U
        · exact opensFundamentalGroupoidHom hOU ≫ c.inl
        · have hOV : O.1 ≤ V := O.2.resolve_left hOU
          exact opensFundamentalGroupoidHom hOV ≫ c.inr
      naturality := by
        classical
        intro A B f
        simp only [Functor.const_obj_obj, Category.comp_id]
        rw [subordinateTwoCoverDiagram_map]
        by_cases hAU : A.1 ≤ U
        · by_cases hBU : B.1 ≤ U
          · dsimp
            rw [dif_pos hAU, dif_pos hBU]
            rw [Category.assoc, opensFundamentalGroupoidHom_comp]
          · have hBV : B.1 ≤ V := B.2.resolve_left hBU
            have hAV : A.1 ≤ V := f.le.trans hBV
            have hAI : A.1 ≤ U ⊓ V := le_inf hAU hAV
            dsimp
            rw [dif_pos hAU, dif_neg hBU]
            calc
              opensFundamentalGroupoidHom f.le ≫
                    (opensFundamentalGroupoidHom hBV ≫ c.inr) =
                  opensFundamentalGroupoidHom hAV ≫ c.inr := by
                    rw [Category.assoc,
                      opensFundamentalGroupoidHom_comp]
              _ =
                  (opensFundamentalGroupoidHom hAI ≫
                      opensFundamentalGroupoidHom
                        (show U ⊓ V ≤ V from inf_le_right)) ≫ c.inr := by
                    rw [opensFundamentalGroupoidHom_comp]
              _ =
                  opensFundamentalGroupoidHom hAI ≫
                    (overlapRightFunctor U V ≫ c.inr) := by
                    rw [Category.assoc]
              _ =
                  opensFundamentalGroupoidHom hAI ≫
                    (overlapLeftFunctor U V ≫ c.inl) := by
                    rw [c.condition]
              _ =
                  (opensFundamentalGroupoidHom hAI ≫
                      opensFundamentalGroupoidHom
                        (show U ⊓ V ≤ U from inf_le_left)) ≫ c.inl := by
                    rw [Category.assoc]
              _ = opensFundamentalGroupoidHom hAU ≫ c.inl := by
                    rw [opensFundamentalGroupoidHom_comp]
        · by_cases hBU : B.1 ≤ U
          · exact (hAU (f.le.trans hBU)).elim
          · have hAV : A.1 ≤ V := A.2.resolve_left hAU
            have hBV : B.1 ≤ V := B.2.resolve_left hBU
            dsimp
            rw [dif_neg hAU, dif_neg hBU]
            rw [Category.assoc, opensFundamentalGroupoidHom_comp] }

/-- At the distinguished member `U`, the extended cocone leg is exactly the
left leg of the original span cocone. -/
theorem subordinateTwoCoverCoconeOfPushout_app_U
    (U V : Opens X)
    (c : PushoutCocone
      (show Grpd.of (FundamentalGroupoid (U ⊓ V)) ⟶
          Grpd.of (FundamentalGroupoid U) from overlapLeftFunctor U V)
      (show Grpd.of (FundamentalGroupoid (U ⊓ V)) ⟶
          Grpd.of (FundamentalGroupoid V) from overlapRightFunctor U V)) :
    (subordinateTwoCoverCoconeOfPushout U V c).ι.app
        (⟨U, Or.inl le_rfl⟩ :
          {O : Opens X // O ∈ subordinateTwoCover U V}) =
      c.inl := by
  dsimp [subordinateTwoCoverCoconeOfPushout]
  rw [dif_pos (show U ≤ U from le_rfl)]
  rw [opensFundamentalGroupoidHom_refl, Category.id_comp]

#print axioms opensFundamentalGroupoidHom_comp
#print axioms subordinateTwoCoverCoconeOfPushout_app_U

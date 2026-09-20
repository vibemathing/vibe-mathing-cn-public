import PoincareVanKampenPushoutKernel
import PoincareConstantHomGroupoidProbe
import PoincareCompatibleBaseArrows
import Mathlib.Topology.Category.TopCat.Opens
import Mathlib.AlgebraicTopology.FundamentalGroupoid.FundamentalGroup

open CategoryTheory CategoryTheory.Limits
open TopologicalSpace

universe u

variable {X : Type u} [TopologicalSpace X]

/-- Continuous inclusion between open subspaces. -/
def opensContinuousInclusion {U V : Opens X} (h : U ≤ V) :
    ContinuousMap U V :=
  ⟨Opens.inclusion h, continuous_inclusion h⟩

/-- Fundamental-groupoid functor induced by an inclusion of opens. -/
abbrev opensFundamentalGroupoidInclusion {U V : Opens X} (h : U ≤ V) :
    FundamentalGroupoid U ⥤ FundamentalGroupoid V :=
  FundamentalGroupoid.map (opensContinuousInclusion h)

/-- Inclusion of opens is injective on fundamental-groupoid objects. -/
theorem opensFundamentalGroupoidInclusion_obj_injective
    {U V : Opens X} (h : U ≤ V) :
    Function.Injective (opensFundamentalGroupoidInclusion h).obj := by
  intro x y hxy
  apply FundamentalGroupoid.ext
  apply Subtype.ext
  exact congrArg
    (fun z : FundamentalGroupoid V => ((z.as : V) : X)) hxy

/-- In a path-connected space, choose one fundamental-groupoid arrow from a
fixed base object to every object. -/
noncomputable def fundamentalGroupoidBaseArrows
    {Y : Type u} [TopologicalSpace Y] [PathConnectedSpace Y]
    (c : FundamentalGroupoid Y) :
    ∀ y : FundamentalGroupoid Y, c ⟶ y :=
  fun y => Path.Homotopic.Quotient.mk
    (PathConnectedSpace.somePath c.as y.as)

/-- Left inclusion of the overlap of a two-open cover. -/
abbrev overlapLeftFunctor (U V : Opens X) :
    FundamentalGroupoid (U ⊓ V : Opens X) ⥤ FundamentalGroupoid U :=
  opensFundamentalGroupoidInclusion (show (U ⊓ V : Opens X) ≤ U from inf_le_left)

/-- Right inclusion of the overlap of a two-open cover. -/
abbrev overlapRightFunctor (U V : Opens X) :
    FundamentalGroupoid (U ⊓ V : Opens X) ⥤ FundamentalGroupoid V :=
  opensFundamentalGroupoidInclusion (show (U ⊓ V : Opens X) ≤ V from inf_le_right)

/-- A strict pushout test cocone for the fundamental-groupoid span of two
path-connected opens.  The hom group is the amalgamated pushout of the two
vertex groups over the overlap vertex group; the object type is the ambient
space itself, so both overlap object maps agree strictly. -/
noncomputable def twoOpenPushoutTestCocone
    (U V : Opens X)
    [PathConnectedSpace (U ⊓ V : Opens X)]
    [PathConnectedSpace U] [PathConnectedSpace V]
    (w₀ : (U ⊓ V : Opens X)) :
    PushoutCocone
      (show Grpd.of (FundamentalGroupoid (U ⊓ V : Opens X)) ⟶
          Grpd.of (FundamentalGroupoid U) from overlapLeftFunctor U V)
      (show Grpd.of (FundamentalGroupoid (U ⊓ V : Opens X)) ⟶
          Grpd.of (FundamentalGroupoid V) from overlapRightFunctor U V) := by
  let FL := overlapLeftFunctor U V
  let FR := overlapRightFunctor U V
  let cW : FundamentalGroupoid (U ⊓ V : Opens X) := FundamentalGroupoid.mk w₀
  let pW := fundamentalGroupoidBaseArrows cW
  let cU := FL.obj cW
  let cV := FR.obj cW
  let fallbackU := fundamentalGroupoidBaseArrows cU
  let fallbackV := fundamentalGroupoidBaseArrows cV
  let hobjU : Function.Injective FL.obj :=
    opensFundamentalGroupoidInclusion_obj_injective
      (show (U ⊓ V : Opens X) ≤ U from inf_le_left)
  let hobjV : Function.Injective FR.obj :=
    opensFundamentalGroupoidInclusion_obj_injective
      (show (U ⊓ V : Opens X) ≤ V from inf_le_right)
  let pU := extendBaseArrows FL cW pW fallbackU hobjU
  let pV := extendBaseArrows FR cW pW fallbackV hobjV
  let G : Bool → Type u := fun b =>
    match b with
    | false => End cU
    | true => End cV
  letI : ∀ b, Group (G b) := fun b => by
    cases b <;> dsimp [G] <;> infer_instance
  let φ : ∀ b, End cW →* G b := fun b =>
    match b with
    | false => FL.mapEnd cW
    | true => FR.mapEnd cW
  let P := Monoid.PushoutI φ
  let leftLeg :
      Grpd.of (FundamentalGroupoid U) ⟶ constantHomGrpd X P :=
    basedTransportToConstantHom
      (fun x => ((x.as : U) : X)) cU pU
      (Monoid.PushoutI.of (φ := φ) false)
  let rightLeg :
      Grpd.of (FundamentalGroupoid V) ⟶ constantHomGrpd X P :=
    basedTransportToConstantHom
      (fun x => ((x.as : V) : X)) cV pV
      (Monoid.PushoutI.of (φ := φ) true)
  refine PushoutCocone.mk leftLeg rightLeg ?_
  rw [Grpd.comp_eq_comp, Grpd.comp_eq_comp]
  apply Functor.ext
  · intro x
    rfl
  · intro x y f
    change Monoid.PushoutI.of false
        (basedTransportMap cU pU (FL.map f)) =
      Monoid.PushoutI.of true
        (basedTransportMap cV pV (FR.map f))
    rw [basedTransportMap_mapEnd_extend FL cW pW fallbackU hobjU f]
    rw [basedTransportMap_mapEnd_extend FR cW pW fallbackV hobjV f]
    let h := basedTransportMap cW pW f
    change Monoid.PushoutI.of false (φ false h) =
      Monoid.PushoutI.of true (φ true h)
    calc
      _ = Monoid.PushoutI.base φ h :=
        Monoid.PushoutI.of_apply_eq_base φ false h
      _ = _ :=
        (Monoid.PushoutI.of_apply_eq_base φ true h).symm

#print axioms opensFundamentalGroupoidInclusion_obj_injective
#print axioms twoOpenPushoutTestCocone

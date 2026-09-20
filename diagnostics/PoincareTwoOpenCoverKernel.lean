import Mathlib.Topology.Category.TopCat.Opens

open TopologicalSpace

universe u

variable {X : Type u} [TopologicalSpace X]

/-- All opens subordinate to one side of a two-open cover. This family is
chosen because it is automatically closed under nonempty finite intersections. -/
def subordinateTwoCover (U V : Opens X) : Set (Opens X) :=
  {O | O ≤ U ∨ O ≤ V}

@[simp]
theorem mem_subordinateTwoCover {U V O : Opens X} :
    O ∈ subordinateTwoCover U V ↔ O ≤ U ∨ O ≤ V :=
  Iff.rfl

/-- If U and V cover X, the subordinate family covers X. -/
theorem subordinateTwoCover_covers (U V : Opens X) (hUV : U ⊔ V = ⊤) :
    ∀ x : X, ∃ O : Opens X, O ∈ subordinateTwoCover U V ∧ x ∈ O := by
  intro x
  have hx : x ∈ U ⊔ V := by
    rw [hUV]
    simp
  rcases Opens.mem_sup.mp hx with hxU | hxV
  · exact ⟨U, Or.inl le_rfl, hxU⟩
  · exact ⟨V, Or.inr le_rfl, hxV⟩

/-- A nonempty finite intersection of subordinate opens is subordinate: choose
any member of the finite family and use that the infimum lies below it. -/
theorem subordinateTwoCover_finiteIntersections (U V : Opens X) :
    ∀ s : Finset (Opens X), s.Nonempty →
      (∀ O ∈ s, O ∈ subordinateTwoCover U V) →
      s.inf (fun O : Opens X => O) ∈ subordinateTwoCover U V := by
  intro s hs hall
  rcases hs with ⟨O, hO⟩
  rcases hall O hO with hOU | hOV
  · exact Or.inl ((Finset.inf_le hO).trans hOU)
  · exact Or.inr ((Finset.inf_le hO).trans hOV)

#print axioms subordinateTwoCover_covers
#print axioms subordinateTwoCover_finiteIntersections

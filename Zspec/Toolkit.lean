namespace Zspec

-- 1. Base Set Theory Definitions
def Set (α : Type) : Type := α → Prop

instance : Membership α (Set α) where
  mem S x := S x

instance : Singleton α (Set α) where
  singleton x := fun y => y = x

instance : Insert α (Set α) where
  insert x S := fun y => y = x ∨ S y

instance : EmptyCollection (Set α) where
  emptyCollection := fun _ => False

instance : Union (Set α) where
  union S T := fun x => S x ∨ T x

instance : Inter (Set α) where
  inter S T := fun x => S x ∧ T x

instance : SDiff (Set α) where
  sdiff S T := fun x => S x ∧ ¬ T x

instance : HasSubset (Set α) where
  Subset S T := ∀ x, S x → T x

-- 2. Relations and Functions
abbrev Rel (α β : Type) : Type := Set (α × β)

def dom {α β : Type} (R : Rel α β) : Set α :=
  fun x => ∃ y, (x, y) ∈ R

def ran {α β : Type} (R : Rel α β) : Set β :=
  fun y => ∃ x, (x, y) ∈ R

def IsFunctional {α β : Type} (R : Rel α β) : Prop :=
  ∀ x y₁ y₂, (x, y₁) ∈ R → (x, y₂) ∈ R → y₁ = y₂

abbrev PartFun (α β : Type) : Type :=
  { R : Rel α β // IsFunctional R }

abbrev TotalFun (α β : Type) : Type :=
  { R : Rel α β // IsFunctional R ∧ ∀ x : α, ∃ y : β, (x, y) ∈ R }

-- 3. Toolkit Operators
def domRes {α β : Type} (S : Set α) (R : Rel α β) : Rel α β :=
  fun p => p.1 ∈ S ∧ p ∈ R

def ranRes {α β : Type} (R : Rel α β) (T : Set β) : Rel α β :=
  fun p => p.2 ∈ T ∧ p ∈ R

def domSub {α β : Type} (S : Set α) (R : Rel α β) : Rel α β :=
  fun p => p.1 ∉ S ∧ p ∈ R

def ranSub {α β : Type} (R : Rel α β) (T : Set β) : Rel α β :=
  fun p => p.2 ∉ T ∧ p ∈ R

def override {α β : Type} (R G : Rel α β) : Rel α β :=
  domSub (dom G) R ∪ G

-- 4. Toolkit Lemmas and Laws
theorem set_ext {α : Type} {S T : Set α} (h : ∀ x, S x ↔ T x) : S = T := by
  funext x
  exact propext (h x)

theorem dom_union {α β : Type} (A B : Rel α β) : dom (A ∪ B) = dom A ∪ dom B := by
  apply set_ext
  intro x
  constructor
  · rintro ⟨y, (hA | hB)⟩
    · left; exact ⟨y, hA⟩
    · right; exact ⟨y, hB⟩
  · rintro (⟨y, hA⟩ | ⟨y, hB⟩)
    · exact ⟨y, Or.inl hA⟩
    · exact ⟨y, Or.inr hB⟩

theorem dom_domSub {α β : Type} (S : Set α) (R : Rel α β) : dom (domSub S R) = fun x => x ∉ S ∧ x ∈ dom R := by
  apply set_ext
  intro x
  constructor
  · rintro ⟨y, hnotin, hmem⟩
    exact ⟨hnotin, ⟨y, hmem⟩⟩
  · rintro ⟨hnotin, ⟨y, hmem⟩⟩
    exact ⟨y, hnotin, hmem⟩

theorem dom_override {α β : Type} (R G : Rel α β) : dom (override R G) = dom R ∪ dom G := by
  rw [override, dom_union, dom_domSub]
  apply set_ext
  intro x
  constructor
  · rintro (⟨hnotin, ⟨y, hmem⟩⟩ | ⟨y, hmem⟩)
    · left; exact ⟨y, hmem⟩
    · right; exact ⟨y, hmem⟩
  · rintro (⟨y, hmem⟩ | ⟨y, hmem⟩)
    · by_cases h : x ∈ dom G
      · right; exact h
      · left; exact ⟨h, ⟨y, hmem⟩⟩
    · right; exact ⟨y, hmem⟩

end Zspec


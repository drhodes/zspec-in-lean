import Zspec.Toolkit
import Zspec.Notation
import Zspec.Schema

open Zspec
open Zspec.Notation

-- Z Given Sets
axiom Name : Type
axiom Date : Type

-- 1. BirthdayBook State Schema
schema BirthdayBook where
  known : Set Name
  birthday : Name ⇸ Date
  inv : known = dom birthday.val

-- 2. InitBirthdayBook Schema
structure InitBirthdayBook where
  toBirthdayBook : BirthdayBook
  init : toBirthdayBook.birthday.val = ∅

-- 3. AddBirthday Operation Schema
structure AddBirthday where
  toDelta : ΔBirthdayBook
  name? : Name
  date? : Date
  pre : name? ∉ toDelta.before.known
  post : toDelta.after.birthday.val = toDelta.before.birthday.val ⊕ {name? ↦ date?}

-- 4. FindBirthday Operation Schema
structure FindBirthday where
  toXi : ΞBirthdayBook
  name? : Name
  date! : Date
  pre : name? ∈ toXi.before.known
  -- Model function application: (name? ↦ date!) ∈ birthday
  post : (name?, date!) ∈ toXi.before.birthday.val

-- 5. Remind Operation Schema
structure Remind where
  toXi : ΞBirthdayBook
  today? : Date
  cards! : Set Name
  post : cards! = fun n => n ∈ toXi.before.known ∧ (n, today?) ∈ toXi.before.birthday.val

-- Theorem: Proving the BirthdayBook known set updates correctly on AddBirthday
theorem add_birthday_known (bb : AddBirthday) :
    bb.toDelta.after.known = bb.toDelta.before.known ∪ {bb.name?} := by
  have inv_after := bb.toDelta.after.inv
  have inv_before := bb.toDelta.before.inv
  have post := bb.post
  rw [inv_after, inv_before, post, dom_override]
  have hdom : dom {bb.name? ↦ bb.date?} = {bb.name?} := by
    apply set_ext
    intro x
    constructor
    · rintro ⟨y, (hy : (x, y) ∈ {bb.name? ↦ bb.date?})⟩
      cases hy
      rfl
    · intro (hx : x = bb.name?)
      exact ⟨bb.date?, by rw [hx]; rfl⟩
  rw [hdom]


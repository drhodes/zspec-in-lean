"""
Specification for the BirthdayBook verification test case in Lean 4.
"""

from .err import Feat, Req


class BirthdayBookTestCase(Feat):
    """
    zspec must formalize Spivey's canonical BirthdayBook specification
    as a complete test case to validate the toolkit and schema calculus.
    """


class BirthdayBookState(Req):
    """
    The BirthdayBook state schema defines the state space of the system.

    It declares:
    - `known : Set Name`
    - `birthday : Name ⇸ Date`
    Invariant:
    - `known = dom birthday`
    """


class InitBirthdayBook(Req):
    """
    The InitBirthdayBook schema specifies the initial state of the birthday book.

    It inherits `BirthdayBook` and asserts the invariant:
    - `birthday = ∅`
    Which implies `known = ∅`.
    """


class AddBirthdayOp(Req):
    """
    The AddBirthday schema specifies adding a birthday to the book.

    It declares:
    - `Δ BirthdayBook`
    - `name? : Name`
    - `date? : Date`
    Precondition:
    - `name? ∉ known`
    Postcondition:
    - `birthday' = birthday ⊕ {name? ↦ date?}` (or equivalent union override).
    """


class FindBirthdayOp(Req):
    """
    The FindBirthday schema specifies looking up a person's birthday.

    It declares:
    - `Ξ BirthdayBook`
    - `name? : Name`
    - `date! : Date`
    Precondition:
    - `name? ∈ known`
    Postcondition:
    - `date! = birthday(name?)` (where function application is modeled).
    """


class RemindOp(Req):
    """
    The Remind schema specifies finding all people with birthdays today.

    It declares:
    - `Ξ BirthdayBook`
    - `today? : Date`
    - `cards! : Set Name`
    Postcondition:
    - `cards! = {n ∈ known | birthday(n) = today?}` (or equivalent set comprehension).
    """


class AddBirthdayTheorem(Req):
    """
    A theorem proving that adding a birthday adds the name to the known set.

    In Lean 4, we must prove:
    `∀ (bb : AddBirthday), bb.known' = bb.known ∪ {bb.name?}`
    using the invariants and postconditions defined in `AddBirthday`.
    """

"""
Specification for the core Z Mathematical Toolkit in Lean 4.
"""

from .err import Feat, Req


class MathematicalToolkit(Feat):
    """
    zspec must formalize the core set-theoretic and relational operators
    of Spivey's Z Mathematical Toolkit using Lean 4.
    """


class RelationType(Req):
    """
    A binary relation X ↔ Y is represented as a set of ordered pairs in Lean 4.

    The type `Rel α β` must be defined as `Set (α × β)`.
    """


class MapletNotation(Req):
    """
    Maplets `x ↦ y` represent ordered pairs in relations.

    Custom infix notation `x ↦ y` must be declared to map to `(x, y)` in Lean 4.
    """


class DomainOperator(Req):
    """
    The domain operator `dom R` returns the set of first components of a relation R.

    Must be defined for any relation `R : Rel α β` as a `Set α`, satisfying:
    `x ∈ dom R ↔ ∃ y, (x, y) ∈ R`.
    """


class RangeOperator(Req):
    """
    The range operator `ran R` returns the set of second components of a relation R.

    Must be defined for any relation `R : Rel α β` as a `Set β`, satisfying:
    `y ∈ ran R ↔ ∃ x, (x, y) ∈ R`.
    """


class PartialFunctionType(Req):
    """
    A partial function X ⇸ Y is represented as a functional binary relation.

    The type `PartFun α β` (or equivalent notation `α ⇸ β`) must be defined as a relation
    where each domain element maps to at most one range element.
    """


class RelationalOverride(Req):
    """
    The relational overriding operator `R ⊕ G` updates relation R with maplets from G.

    For relations `R, G : Rel α β`, `R ⊕ G` is defined as:
    `(R ⊕ G) = (dom G ⩤ R) ∪ G`, where `⩤` is domain anti-restriction.
    It must satisfy that any domain elements in G override their mapping in R,
    while elements only in the domain of R keep their mappings.
    """

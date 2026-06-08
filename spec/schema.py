"""
Specification for Z Schema Calculus and Conventions in Lean 4.
"""

from .err import Feat, Req


class SchemaCalculus(Feat):
    """
    zspec must formalize the Z schema notation and conventions to allow
    declarative state space and operation definitions in Lean 4.
    """


class SchemaCommand(Req):
    """
    A custom `schema` command/macro must allow declaring state spaces and operations.

    It must allow declaring fields (variables with their types) and invariants
    (predicates over the fields) in a single declaration block.
    """


class DeltaConvention(Req):
    """
    The Δ schema convention alerts to a state change.

    For any schema `S`, `Δ S` must automatically be defined to contain:
    - The fields of the "before" state (e.g. `x`, `y` from `S`)
    - The fields of the "after" state (e.g. `x'`, `y'`)
    - The invariants of both "before" and "after" states.
    """


class XiConvention(Req):
    """
    The Ξ schema convention denotes an operation that does not modify the state.

    For any schema `S`, `Ξ S` must automatically be defined. It includes `Δ S`
    and adds the equations enforcing that each before-field equals its corresponding
    after-field (e.g., `x' = x`, `y' = y`).
    """


class SchemaConjunction(Req):
    """
    Schema conjunction conjoins the fields and invariants of two schemas.

    Conjoining schema A and B (represented as A ∧ B) must produce a new schema
    containing the merged variables of A and B (unifying any common variables) and
    asserting the conjoined invariants of A and B.
    """

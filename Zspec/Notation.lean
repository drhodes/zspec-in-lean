import Zspec.Toolkit

namespace Zspec.Notation

-- Maplet notation
-- Choice: Define infix " ↦ " for Prod.mk with high precedence.
infixr:80 " ↦ " => Prod.mk

-- Binary relation type notation
infixr:50 " ⇿ " => Zspec.Rel

-- Function type notations
infixr:50 " ⇸ " => Zspec.PartFun
infixr:50 " ⟶ " => Zspec.TotalFun

-- Restriction and subtraction notations
infixr:65 " ◁ " => Zspec.domRes
infixr:65 " ▷ " => Zspec.ranRes
infixr:65 " ⩤ " => Zspec.domSub
infixr:65 " ⩥ " => Zspec.ranSub

-- Override notation
infixr:60 " ⊕ " => Zspec.override

end Zspec.Notation

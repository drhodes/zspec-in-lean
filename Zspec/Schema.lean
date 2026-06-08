import Lean

open Lean

-- The custom `schema` macro
-- It generates the base structure, the Delta (Δ) state-change structure,
-- and the Xi (Ξ) no-change structure.
macro "schema " name:ident " where " fields:Lean.Parser.Command.structFields : command =>
  let deltaName := mkIdent (name.getId.appendBefore "Δ")
  let xiName := mkIdent (name.getId.appendBefore "Ξ")
  `(structure $name where $fields:structFields

    structure $deltaName where
      before : $name
      after : $name

    structure $xiName where
      before : $name
      after : $name
      unchanged : before = after)

# Bridging Spivey's Z Notation and Lean 4: Implementation Plan & Notes

This document provides a systematic design and planning overview for formalizing the Z specification language—as defined in J. M. Spivey's *The Z Notation: A Reference Manual*—within **Lean 4**. 

It outlines the representation of Z sets and relations, defines mappings for the atomic components of the **Mathematical Toolkit**, details the encoding of schemas and operation conventions ($\Delta$ and $\Xi$), and sets up a specification-driven roadmap aligned with `libspec`.

---

## 1. Core Semantic Translation: Z to Lean 4

Z is based on Zermelo-Fraenkel set theory with types. In Z, every value belongs to a type (a maximal set), and sets are themselves typed. 

In Lean 4, we can represent Z's type-based set theory by parameterizing our definitions with Lean types (`α`, `β`, etc.) and using Lean's `Set` type.

### Z Types as Lean Types
* **Basic Types / Given Sets**: If a Z specification introduces given sets $[NAME, DATE]$, we represent these as arbitrary Lean types `(Name Date : Type)`.
* **Power Sets**: In Z, $\mathbb{P} X$ is the set of all subsets of $X$. In Lean 4, this maps to `Set X`.
* **Cartesian Products**: In Z, $X \times Y$ is the set of ordered pairs. In Lean 4, this is `X × Y`.

### Z Relations and Functions as Sets of Pairs
In Z, relations and functions are *sets of ordered pairs* rather than primitives. This is a crucial semantic point:
* **Binary Relations**: $X \leftrightarrow Y \mathrel{\widehat{=}} \mathbb{P} (X \times Y)$.
  In Lean 4: `def Rel (α β : Type) := Set (α × β)`
* **Partial Functions**: $X \mathbin{\mkern-2mu\not\to\mkern-2mu} Y$ is the set of relations that associate each element of $X$ with at most one element of $Y$.
  In Lean 4:
  ```lean
  structure PartFun (α β : Type) where
    rel : Set (α × β)
    is_functional : ∀ x y₁ y₂, (x, y₁) ∈ rel → (x, y₂) ∈ rel → y₁ = y₂
  ```
* **Total Functions**: $X \to Y$ is the set of partial functions whose domain is the entirety of $X$.
  In Lean 4:
  ```lean
  structure TotalFun (α β : Type) where
    toPartFun : PartFun α β
    is_total : ∀ x : α, ∃ y : β, (x, y) ∈ toPartFun.rel
  ```

---

## 2. Atomic Components of the Z Mathematical Toolkit

The Z Mathematical Toolkit (Spivey, Chapter 4) consists of several groups of operators. To build `zspec`, we must formalize these in Lean 4.

### 2.1 Set Theory (Section 4.1)
| Z Notation | Mathematical Meaning | Proposed Lean 4 Definition / Mapping |
| :--- | :--- | :--- |
| $x \neq y$ | Inequality | `x ≠ y` |
| $x \notin S$ | Non-membership | `x ∉ S` |
| $\varnothing$ | Empty set | `∅` |
| $S \subseteq T$ | Subset relation | `S ⊆ T` |
| $S \subset T$ | Proper subset | `S ⊂ T` |
| $\mathbb{P}_1 S$ | Non-empty subsets | `{ T : Set α // T.Nonempty ∧ T ⊆ S }` |
| $S \cup T$ | Set union | `S ∪ T` |
| $S \cap T$ | Set intersection | `S ∩ T` |
| $S \setminus T$ | Set difference | `S \ T` |
| $\bigcup A$ | Generalized union | `⋃₀ A` (union of set of sets) |
| $\bigcap A$ | Generalized intersection | `⋂₀ A` |

### 2.2 Relations (Section 4.2)
Let $R : \text{Rel } \alpha\ \beta$ (i.e., $R : \text{Set } (\alpha \times \beta)$):

| Z Operator | Meaning | LaTeX symbol | Lean 4 Implementation |
| :--- | :--- | :--- | :--- |
| $x \mapsto y$ | Maplet (pair) | `\mapsto` | `(x, y)` |
| $\text{dom } R$ | Domain | `\dom` | `{ x : α \| ∃ y, (x, y) ∈ R }` |
| $\text{ran } R$ | Range | `\ran` | `{ y : β \| ∃ x, (x, y) ∈ R }` |
| $\text{id } S$ | Identity relation | `\id` | `{ p : α × α \| p.1 ∈ S ∧ p.1 = p.2 }` |
| $R_1 \mathbin{\circ} R_2$ | Backward composition | `\circ` | `{ (x, z) \| ∃ y, (x, y) ∈ R_1 ∧ (y, z) ∈ R_2 }` |
| $R_1 \mathbin{\circ} R_2$ | Forward composition | `\comp` | Same as composition, but in reverse order |
| $S \triangleleft R$ | Domain restriction | `\dres` | `{ (x, y) ∈ R \| x ∈ S }` |
| $R \triangleright T$ | Range restriction | `\rres` | `{ (x, y) ∈ R \| y ∈ T }` |
| $S \mathbin{\mkern-2mu\triangleleft\mkern-7mu\setminus\mkern-2mu} R$ | Domain subtraction | `\ndres` | `{ (x, y) ∈ R \| x ∉ S }` |
| $R \mathbin{\triangleright\mkern-7mu\setminus\mkern-2mu} T$ | Range subtraction | `\nrres` | `{ (x, y) ∈ R \| y ∉ T }` |
| $R^{\sim}$ | Relational inversion | `~` | `{ (y, x) \| (x, y) ∈ R }` |
| $R(\mkern-2mu\lvert S \rvert\mkern-2mu)$ | Relational image | `\limg S \rimg` | `{ y : β \| ∃ x ∈ S, (x, y) ∈ R }` |
| $R_1 \oplus R_2$ | Overriding | `\oplus` | `(dom R_2 ⩤ R_1) ∪ R_2` |
| $R^+$ | Transitive closure | `\plus` | Inductively defined transitive closure |
| $R^*$ | Reflexive-transitive | `\star` | Inductively defined reflexive transitive closure |

---

## 3. Modeling Z Schemas in Lean 4

A Z schema consists of a signature (variable declarations) and a predicate (property constraint). They represent both state spaces and state transitions.

### 3.1 State Schemas
Consider a simple schema representing a database of user ages:
```
--- UserDB ---
users : P NAME
age : NAME -+> N
--------------
dom age = users
--------------
```
We model this in Lean 4 as a `structure` containing:
1. Declarations as structure fields.
2. Invariant constraints as proof fields (predicates).

```lean
structure UserDB (Name : Type) where
  users : Set Name
  age : Set (Name × Nat)
  age_functional : ∀ x y₁ y₂, (x, y₁) ∈ age → (x, y₂) ∈ age → y₁ = y₂
  invariant : { x | ∃ y, (x, y) ∈ age } = users
```

### 3.2 Operation Schemas ($\Delta$ and $\Xi$ Conventions)
In Z:
* $\Delta Schema$ introduces the variables of $Schema$ (before-state) and $Schema'$ (after-state) to represent a change of state.
* $\Xi Schema$ represents an operation that does not change the state ($Schema' = Schema$).

In Lean 4, we can define these transitions by composing structures:

```lean
-- Delta transition
structure DeltaUserDB (Name : Type) where
  before : UserDB Name
  after : UserDB Name

-- Xi transition (state remains unchanged)
structure XiUserDB (Name : Type) where
  toDelta : DeltaUserDB Name
  unchanged : toDelta.before = toDelta.after
```

Operations are then structures that extend `DeltaUserDB` with additional input/output variables and operation-specific preconditions/postconditions:
```lean
-- Operation to add a user
structure AddUser (Name : Type) extends DeltaUserDB Name where
  user? : Name
  age? : Nat
  
  -- Precondition: user? not already in database
  precondition : user? ∉ before.users
  
  -- Postconditions:
  after_users : after.users = before.users ∪ {user?}
  after_age : after.age = before.age ∪ {(user?, age?)}
```

---

## 4. Driving the Bridge via `libspec`

To implement `zspec` using our established development guidelines, we will decompose the Z specification manual chapters into modular requirements. This guarantees that our Lean 4 formalization has clean traceability and high test coverage.

### 4.1 Granular Requirement Specifications (`spec/*.py`)
We will create a series of specification modules under `spec/`:

1. `spec/set_toolkit.py`: Specifies atomic set operators (inequality, non-membership, power sets, generalized union/intersection).
2. `spec/rel_toolkit.py`: Specifies binary relation operators (domain, range, restrictions, compositions, inversion, image, overriding, and closures).
3. `spec/fun_toolkit.py`: Specifies partial and total function properties (injections, surjections, bijections).
4. `spec/schema_calculus.py`: Specifies the schema structure, $\Delta$ / $\Xi$ state transition bindings, and logical combinators.

Each requirement class (e.g. `DomainRestrictionReq`, `RelationalOverridingReq`) will map directly to a Lean definition and an associated theorem showing correctness under the laws specified in `zrm.tex`.

### 4.2 Development Workflow Steps
1. **Define Specs**: Under `spec/`, create the decomposed requirement classes.
2. **Compile Specs**: Run `libspec build spec/main_spec.py` to ensure everything registers.
3. **Diff Check**: Run `uv run libspec diff` to verify the baseline specifications.
4. **Lean Tests**: Write test cases in Lean (e.g. using `run_cmd` or by writing proof validations/theorems that assert the laws from Spivey's manual).
5. **Lean Implementation**: Code the formal definitions in `Zspec/Basic.lean` (or submodules like `Zspec/Set.lean`, `Zspec/Rel.lean`, `Zspec/Func.lean`).
6. **Commit**: Write a comprehensive git commit message outlining the added formalizations.

---

## 5. Lean 4 Metaprogramming & Custom Elaboration Design

To align `zspec` as closely as possible with Z notation's concrete syntax and schema calculus idioms, we will leverage Lean 4's powerful macro, syntax, and elaboration (metaprogramming) facilities.

### 5.1 Custom Syntax Rules (The Mathematical Toolkit Notation)
Lean 4 allows declaring custom notations, binders, and priorities. We can declare the Z toolkit operators directly:

```lean
-- Maplet notation
notation:max x " ↦ " y => (x, y)

-- Relations and Functions notation
infixr:40 " ↔ " => Rel
infixr:45 " ⇸ " => PartFun
infixr:45 " → " => TotalFun

-- Restriction, subtraction, overriding, and composition
infixr:55 " ◁ " => dres
infixr:55 " ▷ " => rres
infixr:55 " ⩤ " => ndres
infixr:55 " ⩥ " => nrres
infixr:60 " ⊕ " => override
infixr:65 " ⨾ " => forward_comp
```

### 5.2 Custom Command Elaboration: `schema`
Rather than writing verbose Lean structures with manual invariants and helper transition types, we can define a custom `schema` command.

We can define a syntax rule:
```lean
syntax "schema" ident (brackets)* "where" 
  (ident ":" term)* 
  ("invariant" ":" term)? : command
```

And write a macro or command elaborator (`elab_rules`) that:
1. Generates the base `structure <Name>` with the specified fields and invariants.
2. Automatically generates the corresponding $\Delta <Name>$ structure:
   ```lean
   structure Delta<Name> where
     before : <Name>
     after : <Name>
   ```
3. Automatically generates the corresponding $\Xi <Name>$ structure:
   ```lean
   structure Xi<Name> extends Delta<Name> where
     unchanged : before = after
   ```

### 5.3 Metaprogramming the Schema Calculus
To support logical combinations of schemas (e.g., $C \mathrel{\widehat{=}} A \land B$), we will implement a command macro `schema_conj C A B` (or dynamic notation `schema C := A ∧ B`) that:
1. Obtains the definitions of structures `A` and `B` from Lean's environment (`Lean.Environment`).
2. Iterates over their fields to construct a union list of declarations.
3. Merges duplicate fields (validating that they have matching types) and reports errors if types clash.
4. Conjoins the predicates of `A` and `B` to form the new invariant.
5. Emits a new structure `C` containing the merged fields and invariants.

This metaprogramming approach bridges the static-typing gap of Lean 4 structures and provides a first-class, ergonomic Z specification experience.

---

## 6. Next Steps & Action Plan

Before coding `zspec` in Lean 4:
1. Create the `spec/` folder and setup `main_spec.py` with `libspec` configurations.
2. Decompose the relation toolkit laws (domain/range restriction, domain/range subtraction, overriding) into `spec/rel_toolkit.py`.
3. Set up the file structure in Lean 4:
   ```
   Zspec/
   ├── Notation.lean -- Custom syntax and toolkit notations
   ├── Set.lean      -- Set theory toolkit
   ├── Rel.lean      -- Binary relations, compositions, restrictions, overriding
   ├── Func.lean     -- Function classifications
   ├── Schema.lean   -- Metaprogramming command elaborator for `schema`
   └── Basic.lean    -- Root imports
   ```

*Notes prepared by Antigravity AI.*


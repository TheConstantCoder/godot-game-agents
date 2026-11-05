# Architecture

Owned by the `game-architect` agent. Entries are `Proposed` until the user says yes, then `Adopted (D<N>, user YYYY-MM-DD)`, or `Rejected`.

## Layers
`<diagram and dependency rules, e.g. logic ← world/actors ← ui; logic never imports a Node>`

## Archetypes
### Def — `Adopted (D<N>)`
- **Members:** `extends Resource`, `class_name XDef`, `@export` fields only, `id: StringName`.
- **Folder:** `<common/defs/>` · **May depend on:** other Defs · **Save:** by id only · **Test:** loads every `.tres` and checks ids are unique.
- **Reference file:** `<path>` · **Check:** `<grep or test that fails when broken>`

## Decisions
- `<short title>` (D<N>) — `<status>`

## Refactor register
| Finding | Size | Phase | Status |
| --- | --- | --- | --- |

## Watch list
- `<pattern seen twice; standardise at three>`

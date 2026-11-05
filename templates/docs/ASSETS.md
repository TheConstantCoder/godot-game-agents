# Assets

The asset contract and inventory. Imports are checked against the contract; the plan maps each asset to the phase that needs it.

## Contract
- **Scale and pivot:** 1 unit = 1 m; pivot at the base centre; facing −Z.
- **Node names:** `<e.g. %Door, %Sign, Marker3D "Spawn">` — code finds parts by these names, so stand-ins use them too.
- **Materials:** `<shared look material slots, surface tags for footsteps or bullets>`
- **Audio slots:** `<bus names, one-shot vs loop, loudness target>`
- **Folders:** imported binaries in `<assets/>`; authored look resources in `<common/look/>`.

## Inventory
| Asset | Needed by | Source | Licence | Status |
| --- | --- | --- | --- | --- |
| `<crate>` | M0 | `<kit or tool>` | `<CC0>` | stand-in |

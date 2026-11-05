# Decisions

The decision and defect log. Every settled question gets the next id; agents search this file before deciding anything. Append only: to change a decision, add a new entry that supersedes the old one, and note it on both.

**Next id:** D3

---

- **D1** (YYYY-MM-DD, user) **Docs lead, code follows.** ROADMAP and PLAN decide mechanics, ART_DIRECTION decides look, UI and sound, ARCHITECTURE decides structure. Code that disagrees with the docs is a bug in one of them; log which.
- **D2** (YYYY-MM-DD, team-lead) **Inventory is plain data.** `Inventory` is a `RefCounted` with `to_dict`/`from_dict`, owned by the game layer; the UI reads it through a view. Why: saves and tests without a scene tree.

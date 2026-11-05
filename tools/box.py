#!/usr/bin/env python3
"""Prints one plan box and a one-line digest of each decision entry it cites, so a small model
never has to read the whole plan or decision log.

  box.py <words from the box title>   the box, then each cited decision id (first 240 chars)
  box.py --decisions D12 D14.2        the full entries for those ids
  box.py --lint <ticket name or path> refuses a hand-off ticket that misses a template part
                                      (templates/tickets/README.md), names no test, names a file
                                      outside the hand-off areas, or is over the token budget

Run it as: python3 -I tools/box.py ...
Settings (environment):
  PLAN_FILE        default docs/PLAN.md
  DECISIONS_FILE   default docs/DECISIONS.md
  DECISION_PREFIX  default D (entries look like "- **D12** ...")
  HANDOFF_AREAS    comma-separated path prefixes a hand-off may edit (default: no limit)
  TICKET_TOKENS    default 1500
"""
import os
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
PLAN = os.environ.get("PLAN_FILE", "docs/PLAN.md")
DECISIONS = os.environ.get("DECISIONS_FILE", "docs/DECISIONS.md")
PREFIX = os.environ.get("DECISION_PREFIX", "D")
AREAS = tuple(a for a in os.environ.get("HANDOFF_AREAS", "").split(",") if a)
TICKET_TOKENS = int(os.environ.get("TICKET_TOKENS", "1500"))
BOX_START = re.compile(r"^- \[[ x]\] ")
DEC_ID = re.compile(r"\b%s(\d+(?:\.\d+)?)\b" % re.escape(PREFIX))
DIGEST_CHARS = 240
FULL_CHARS = 6000
TICKET_HEADERS = ("**Branch:**", "**Box:**")
TICKET_SECTIONS = ("## Goal", "## Settled rules", "## Files", "## Steps", "## Done when")
PATH_TOKEN = re.compile(r"`(?:res://)?([\w.<>%*-]+(?:/[\w.<>%*-]+)+\.\w+)`")


def read_lines(name: str) -> list[str]:
    path = ROOT / name
    if not path.exists():
        sys.exit(f"box.py: {name} not found under {ROOT}")
    return path.read_text(encoding="utf-8").split("\n")


def boxes(lines: list[str]) -> list[list[str]]:
    out: list[list[str]] = []
    cur: list[str] | None = None
    for line in lines:
        if BOX_START.match(line):
            cur = [line]
            out.append(cur)
        elif cur is not None and line.startswith(" ") and line.strip():
            cur.append(line)
        else:
            cur = None
    return out


def title_of(first_line: str) -> str:
    m = re.search(r"\*\*(.+?)\*\*", first_line)
    return m.group(1) if m else first_line


def entry(lines: list[str], did: str) -> str | None:
    """The entry's own line plus its indented body lines, up to the next entry."""
    pat = re.compile(r"^(\s*)- \*\*%s%s\b" % (re.escape(PREFIX), re.escape(did)))
    nxt_entry = re.compile(r"^\s*- \*\*%s\d" % re.escape(PREFIX))
    for i, line in enumerate(lines):
        m = pat.match(line)
        if not m:
            continue
        indent = len(m.group(1))
        body: list[str] = []
        for nxt in lines[i + 1:]:
            if not nxt.strip() or len(nxt) - len(nxt.lstrip()) <= indent or nxt_entry.match(nxt):
                break
            body.append(nxt.strip())
        return " ".join([line.strip()] + body)
    return None


def show_decisions(ids: list[str]) -> None:
    lines = read_lines(DECISIONS)
    for did in ids:
        did = did.lstrip(PREFIX + PREFIX.lower())
        found = entry(lines, did)
        if found is None:
            print(f"{PREFIX}{did}: no entry found")
            continue
        print(found[:FULL_CHARS] + (" ...[cut]" if len(found) > FULL_CHARS else "") + "\n")


def show_box(words: list[str]) -> None:
    want = " ".join(words).lower()
    found = [b for b in boxes(read_lines(PLAN)) if want in title_of(b[0]).lower()]
    if not found:
        sys.exit(f"box.py: no box title in {PLAN} contains '{want}'")
    if len(found) > 1:
        print(f"box.py: {len(found)} boxes match '{want}'; use more words:")
        for b in found:
            print("  " + b[0][:100])
        sys.exit(1)
    text = "\n".join(found[0])
    print(text + "\n")
    ids = list(dict.fromkeys(DEC_ID.findall(text)))
    if not ids or not (ROOT / DECISIONS).exists():
        return
    dec = read_lines(DECISIONS)
    print(f"Cited decisions (full text: box.py --decisions <id>):")
    for did in ids:
        found_entry = entry(dec, did)
        if found_entry is not None:
            print("  " + found_entry[:DIGEST_CHARS] + (" ..." if len(found_entry) > DIGEST_CHARS else ""))


def section(lines: list[str], head: str) -> list[str]:
    out: list[str] = []
    on = False
    for line in lines:
        if line.startswith("## "):
            on = line.strip() == head
        elif on:
            out.append(line)
    return out


def lint_problems(text: str) -> list[str]:
    lines = text.split("\n")
    problems: list[str] = []
    for h in TICKET_HEADERS:
        if not any(line.startswith(h) for line in lines):
            problems.append(f"no {h} line")
    for s in TICKET_SECTIONS:
        if not any(line.strip() == s for line in lines):
            problems.append(f"no '{s}' section")
    files = "\n".join(section(lines, "## Files"))
    if not re.search(r"\btest_\w+\.gd\b", files):
        problems.append("'## Files' names no test_*.gd")
    if AREAS:
        for path in PATH_TOKEN.findall(files):
            if not path.startswith(AREAS):
                problems.append(f"{path} is outside the hand-off areas ({', '.join(AREAS)})")
    tokens = len(text) // 4
    if tokens > TICKET_TOKENS:
        problems.append(f"about {tokens} tokens, over the {TICKET_TOKENS} budget")
    return problems


def lint(name: str) -> None:
    path = pathlib.Path(name)
    if not path.is_file():
        path = ROOT / "tickets" / (name.removesuffix(".md") + ".md")
    if not path.is_file():
        sys.exit(f"box.py: no ticket {name}")
    text = path.read_text(encoding="utf-8")
    problems = lint_problems(text)
    for p in problems:
        print("  - " + p)
    if problems:
        print(f"TICKET_FAILED: {path.name} ({len(problems)} problems)")
        sys.exit(1)
    print(f"TICKET_OK: {path.name} (about {len(text) // 4} tokens)")


def main() -> None:
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    if args[0] == "--decisions":
        show_decisions(args[1:])
    elif args[0] == "--lint" and len(args) == 2:
        lint(args[1])
    else:
        show_box(args)


main()

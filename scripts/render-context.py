#!/usr/bin/env python3
"""Render generated consumers from anchors/registry.yaml.

The registry is the single source of truth. AGENTS.md, CLAUDE.md, and the Claude
Code output style are generated. Never hand-edit a generated file.

Usage:
    python3 scripts/render-context.py --target agents  > AGENTS.md
    python3 scripts/render-context.py --target style   > output-styles/agentic-writing.md
    python3 scripts/render-context.py --target table   # markdown table for docs/
"""
import argparse
import pathlib
import sys
import textwrap

try:
    import yaml
except ImportError:
    sys.exit("pip install pyyaml")

ROOT = pathlib.Path(__file__).resolve().parent.parent
REGISTRY = ROOT / "anchors" / "registry.yaml"
BANNER = "<!-- GENERATED FILE. Source: anchors/registry.yaml. Run scripts/render-context.py. -->"


def load():
    with REGISTRY.open() as fh:
        return yaml.safe_load(fh)


INTRO = (
    "You write text that another agent or a non-native reader must parse without a "
    "back-channel. Follow the anchors below. Each anchor names a public standard, so you "
    "can resolve it from the name alone. A more specific instruction from the user or from "
    "the file you edit takes precedence on whatever it addresses."
)

VERIFY = [
    "Run `vale <path>` before you report the work as done. A finding names a rule. A rule "
    "names a clause. If you disagree with a finding, say which rule and why. Do not silence "
    "a rule to make the output pass.",
    "Vale checks part of ASD-STE100, not all of it. `vale` exit code 0 means \"no finding "
    "at or above the gate\", not \"compliant\".",
]

WIDTH = 90


def agents(reg):
    """The model-context contract.

    Prose lives here because it describes the contract as a whole. Per-anchor text
    lives in the registry under `context`. An anchor with no `context` block is not
    part of the contract and is omitted — arc42 is the current example.
    """
    listed = sorted(
        (a for a in reg["anchors"] if a.get("context")),
        key=lambda a: a["context"]["order"],
    )

    out = [BANNER, "# Writing contract", "", textwrap.fill(INTRO, WIDTH, break_on_hyphens=False), ""]
    for a in listed:
        c = a["context"]
        out.append(
            textwrap.fill(
                f"**{c['label']}** — {' '.join(c['text'].split())}",
                WIDTH,
                initial_indent="- ",
                subsequent_indent="  ",
                break_on_hyphens=False,
            )
        )
    out += ["", "## Verify before you claim compliance", ""]
    for para in VERIFY:
        out += [textwrap.fill(para, WIDTH, break_on_hyphens=False), ""]
    return "\n".join(out).rstrip("\n")


def table(reg):
    rows = ["| Anchor | Standard | Coverage | Rules |", "|---|---|---|---|"]
    for a in reg["anchors"]:
        v = a["verifier"]
        rows.append(
            f"| `{a['id']}` | [{a['name']}]({a['url']}) | {v.get('coverage')} | "
            f"{len(v.get('rules') or [])} |"
        )
    return "\n".join(rows)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--target", choices=["agents", "table"], default="agents")
    args = p.parse_args()
    reg = load()
    print({"agents": agents, "table": table}[args.target](reg))


if __name__ == "__main__":
    main()

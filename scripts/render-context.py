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


def agents(reg):
    out = [BANNER, "# Writing contract", ""]
    for a in reg["anchors"]:
        out.append(f"- **{a['name']}** — {a['invoke_as'].strip()}")
    out += [
        "",
        "## Verify before you claim compliance",
        "",
        "Run `vale <path>` before you report the work as done. A finding names a rule.",
        "A rule names a clause in a public standard.",
        "",
    ]
    partial = [a["id"] for a in reg["anchors"] if a["verifier"].get("coverage") != "full"]
    out.append(f"Vale coverage is not full for: {', '.join(partial)}.")
    return "\n".join(out)


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

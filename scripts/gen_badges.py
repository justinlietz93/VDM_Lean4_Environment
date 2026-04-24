#!/usr/bin/env python3
"""gen_badges.py -- local preview of the shields.io badge JSONs.

Runs `lake build` in each packages/* directory that has a lakefile,
captures pass/fail, counts top-level `theorem` declarations, and writes
badges/<package>.json in the shields.io `endpoint` schema.

The real badge publishing happens in CI (.github/workflows/build.yml).
This script exists for local sanity-checking before pushing.
"""

from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
PACKAGES_DIR = ROOT / "packages"
BADGES_DIR = ROOT / "badges"

_THEOREM_RE = re.compile(r"^\s*theorem\b", re.MULTILINE)


def iter_packages() -> list[Path]:
    return [
        p for p in sorted(PACKAGES_DIR.iterdir())
        if (p / "lakefile.toml").exists() and not p.name.startswith("_")
    ]


def count_theorems(pkg: Path) -> int:
    count = 0
    for lean_file in pkg.rglob("*.lean"):
        count += len(_THEOREM_RE.findall(lean_file.read_text(encoding="utf-8")))
    return count


def build(pkg: Path) -> tuple[bool, str]:
    try:
        result = subprocess.run(
            ["lake", "build"],
            cwd=pkg,
            check=False,
            capture_output=True,
            text=True,
            timeout=600,
        )
        return result.returncode == 0, result.stdout + result.stderr
    except FileNotFoundError:
        return False, "lake not found in PATH"
    except subprocess.TimeoutExpired:
        return False, "build timeout (10 minutes)"


def make_badge(name: str, ok: bool, theorem_count: int) -> dict:
    return {
        "schemaVersion": 1,
        "label": f"Lean: {name}",
        "message": f"{'pass' if ok else 'fail'} \u00b7 {theorem_count} theorems",
        "color": "brightgreen" if ok else "red",
    }


def main() -> int:
    BADGES_DIR.mkdir(exist_ok=True)
    total_failures = 0

    for pkg in iter_packages():
        name = pkg.name
        thms = count_theorems(pkg)
        ok, log = build(pkg)
        badge = make_badge(name, ok, thms)
        badge_path = BADGES_DIR / f"{name}.json"
        badge_path.write_text(json.dumps(badge, indent=2) + "\n", encoding="utf-8")
        status = "PASS" if ok else "FAIL"
        print(f"{status:4s} {name:28s} theorems={thms:3d}  ->  {badge_path}")
        if not ok:
            total_failures += 1
            print("  build log tail:")
            for line in log.splitlines()[-10:]:
                print(f"    {line}")

    return 1 if total_failures else 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Documentation guardrails for active docs and naming policy."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path
from typing import Iterable, List

REPO_ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = REPO_ROOT / "docs/library/DOCUMENT_REGISTRY.md"

ACTIVE_DOC_RE = re.compile(r"^\s*\d+\.\s+`([^`]+\.md)`\s*$")
MD_LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
FORBIDDEN_TOKEN_RE = re.compile(r"(^|[_\W])(TEMP|STATUS|OLD)([_\W]|$)", re.IGNORECASE)


def _run_git(args: List[str]) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=REPO_ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout


def parse_active_docs() -> list[Path]:
    if not REGISTRY_PATH.exists():
        raise FileNotFoundError(f"Missing registry: {REGISTRY_PATH}")

    files: list[Path] = []
    for line in REGISTRY_PATH.read_text(encoding="utf-8").splitlines():
        match = ACTIVE_DOC_RE.match(line)
        if match:
            files.append(REPO_ROOT / match.group(1))

    if not files:
        raise ValueError("No active documentation entries found in registry")

    return files


def extract_local_links(markdown_text: str) -> Iterable[str]:
    for target in MD_LINK_RE.findall(markdown_text):
        if target.startswith(("http://", "https://", "mailto:")):
            continue
        if target.startswith("#"):
            continue
        yield target


def check_active_links(active_docs: Iterable[Path]) -> list[str]:
    errors: list[str] = []
    for doc_path in active_docs:
        if not doc_path.exists():
            errors.append(f"Active document is missing: {doc_path.relative_to(REPO_ROOT)}")
            continue

        content = doc_path.read_text(encoding="utf-8")
        for raw_target in extract_local_links(content):
            target = raw_target.split("#", 1)[0].strip()
            if not target:
                continue

            resolved = (doc_path.parent / target).resolve()
            if not resolved.exists():
                errors.append(
                    f"Broken link in {doc_path.relative_to(REPO_ROOT)} -> {raw_target}"
                )

    return errors


def added_markdown_files(base_ref: str | None) -> list[Path]:
    if base_ref:
        diff_output = _run_git(["diff", "--name-status", "--diff-filter=A", f"{base_ref}...HEAD"])
    else:
        diff_output = _run_git(["diff", "--cached", "--name-status", "--diff-filter=A"])

    files: list[Path] = []
    for line in diff_output.splitlines():
        if not line:
            continue
        status, rel = line.split("\t", 1)
        if status != "A" or not rel.endswith(".md"):
            continue
        files.append(REPO_ROOT / rel)
    return files


def check_new_status_docs(base_ref: str | None) -> list[str]:
    errors: list[str] = []
    for file_path in added_markdown_files(base_ref):
        rel = file_path.relative_to(REPO_ROOT)
        if rel.parts[:2] == ("docs", "archive"):
            continue

        name = rel.name
        if not FORBIDDEN_TOKEN_RE.search(name):
            continue

        if name.upper().startswith("ARCHIVE_"):
            continue

        errors.append(
            "New TEMP/STATUS/OLD document must use ARCHIVE_ prefix or be placed under docs/archive/: "
            f"{rel}"
        )
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--base",
        help="Git ref used to detect newly added markdown docs (e.g. origin/main).",
    )
    args = parser.parse_args()

    errors: list[str] = []
    active_docs = parse_active_docs()
    errors.extend(check_active_links(active_docs))
    errors.extend(check_new_status_docs(args.base))

    if errors:
        print("docs_guard checks failed:")
        for err in errors:
            print(f" - {err}")
        return 1

    print("docs_guard checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())

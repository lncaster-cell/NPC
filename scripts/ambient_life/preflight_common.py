from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def read_json_list_input(path: Path, *, key: str) -> list[dict[str, Any]]:
    """Read JSON that can be either root array or object with required list key."""
    payload = json.loads(path.read_text(encoding="utf-8"))

    if isinstance(payload, dict):
        if key not in payload:
            raise ValueError(f"missing required key '{key}'")
        rows = payload[key]
    elif isinstance(payload, list):
        rows = payload
    else:
        raise ValueError(f"JSON root must be an object with key '{key}' or an array")

    if not isinstance(rows, list):
        raise ValueError(f"'{key}' must be an array")

    return rows


def read_json_object_input(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError("JSON root must be an object")
    return payload


def is_strict_int(value: Any) -> bool:
    # Exclude bool explicitly: JSON boolean is not a valid integer value for route/locals config fields.
    return isinstance(value, int) and not isinstance(value, bool)


def read_tag(value: Any) -> str | None:
    if not isinstance(value, str):
        return None
    tag = value.strip()
    return tag or None


def tag_error_code(value: Any, *, missing_code: str, invalid_type_code: str) -> str:
    if value is None or (isinstance(value, str) and value.strip() == ""):
        return missing_code
    return invalid_type_code

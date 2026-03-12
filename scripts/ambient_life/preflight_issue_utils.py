from __future__ import annotations

from typing import Any


def make_issue_context(message: str) -> dict[str, Any]:
    return {"message": message}


def render_issue_message(code: str, context: dict[str, Any]) -> str:
    message = context.get("message")
    if isinstance(message, str):
        return message

    parts = context.get("parts")
    if isinstance(parts, (list, tuple)):
        return "".join(str(part) for part in parts)

    return code

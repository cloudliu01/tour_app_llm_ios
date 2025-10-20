#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: update-agent-context.sh <agent-name>" >&2
  exit 1
fi

AGENT_NAME="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

FEATURES_DIR="${REPO_ROOT}/.specify/features"

LATEST_FEATURE_DIR="$(find "${FEATURES_DIR}" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
if [[ -z "${LATEST_FEATURE_DIR}" ]]; then
  echo "Error: no feature directories available" >&2
  exit 1
fi

SPEC_FILE="${LATEST_FEATURE_DIR}/spec.md"
RESEARCH_FILE="${LATEST_FEATURE_DIR}/research.md"
PLAN_FILE="${LATEST_FEATURE_DIR}/plan.md"

if [[ ! -f "${SPEC_FILE}" || ! -f "${RESEARCH_FILE}" || ! -f "${PLAN_FILE}" ]]; then
  echo "Error: expected spec, research, and plan files in ${LATEST_FEATURE_DIR}" >&2
  exit 1
fi

AGENT_DIR="${REPO_ROOT}/.specify/memory/agents"
mkdir -p "${AGENT_DIR}"

AGENT_FILE="${AGENT_DIR}/${AGENT_NAME}.md"

export UPDATE_AGENT_FILE="${AGENT_FILE}"
export UPDATE_SPEC_FILE="${SPEC_FILE}"
export UPDATE_RESEARCH_FILE="${RESEARCH_FILE}"
export UPDATE_PLAN_FILE="${PLAN_FILE}"
export UPDATE_AGENT_NAME="${AGENT_NAME}"

python3 <<'PY'
import os
from pathlib import Path
import re

agent_file = Path(os.environ["UPDATE_AGENT_FILE"])
spec_file = Path(os.environ["UPDATE_SPEC_FILE"])
research_file = Path(os.environ["UPDATE_RESEARCH_FILE"])
plan_file = Path(os.environ["UPDATE_PLAN_FILE"])
agent_name = os.environ["UPDATE_AGENT_NAME"]

def ensure_base_content(path: Path) -> str:
    title = f"# Agent Context — {agent_name.capitalize()}\n\n"
    auto_marker = "<!-- AUTO-GENERATED CONTEXT START -->\n"
    auto_end = "<!-- AUTO-GENERATED CONTEXT END -->\n"
    manual_marker = "<!-- MANUAL NOTES START -->\n"
    manual_end = "<!-- MANUAL NOTES END -->\n"
    default_manual = "No manual notes recorded yet.\n"
    if not path.exists():
        return title + auto_marker + auto_end + "\n" + manual_marker + default_manual + manual_end + "\n"
    content = path.read_text()
    if "<!-- AUTO-GENERATED CONTEXT START -->" not in content:
        content = title + auto_marker + auto_end + "\n" + content
    if "<!-- MANUAL NOTES START -->" not in content:
        content = content.rstrip() + "\n" + manual_marker + default_manual + manual_end + "\n"
    return content

def extract_section(text: str, heading: str) -> str:
    pattern = rf"## {re.escape(heading)}\n((?:.|\n)*?)(?=^## |\Z)"
    match = re.search(pattern, text, re.MULTILINE)
    return match.group(1) if match else ""

base_content = ensure_base_content(agent_file)

research_text = research_file.read_text()
spec_text = spec_file.read_text()
plan_text = plan_file.read_text()

decision_lines = []
for line in research_text.splitlines():
    if line.startswith("- **Decision**:"):
        decision_lines.append("- " + line.split(": ", 1)[1])

success_section = extract_section(spec_text, "Success Criteria")
for line in success_section.splitlines():
    if line.strip().startswith("- "):
        decision_lines.append(line.strip())

known_decision_match = re.search(r"- Known Decisions: (.+)", plan_text)
if known_decision_match:
    parts = [segment.strip() for segment in known_decision_match.group(1).split(";")]
    for part in parts:
        if part:
            decision_lines.append(f"- Known Decision: {part}")

unique_lines = []
seen = set()
for line in decision_lines:
    if line not in seen:
        unique_lines.append(line)
        seen.add(line)

auto_block = "\n".join(unique_lines) + ("\n" if unique_lines else "")

auto_start = "<!-- AUTO-GENERATED CONTEXT START -->"
auto_end = "<!-- AUTO-GENERATED CONTEXT END -->"

before, _, remainder = base_content.partition(auto_start)
_, _, after = remainder.partition(auto_end)

new_content = before + auto_start + "\n" + auto_block + auto_end + after

agent_file.write_text(new_content)
PY

echo "Updated agent context for ${AGENT_NAME} at ${AGENT_FILE}"

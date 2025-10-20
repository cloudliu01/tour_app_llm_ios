#!/usr/bin/env bash

set -euo pipefail

REQUIRE_TASKS=false
INCLUDE_TASKS=false

if [[ $# -lt 1 ]]; then
  echo "Usage: check-prerequisites.sh --json [--require-tasks] [--include-tasks]" >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      shift
      ;;
    --require-tasks)
      REQUIRE_TASKS=true
      shift
      ;;
    --include-tasks)
      INCLUDE_TASKS=true
      shift
      ;;
    *)
      echo "Usage: check-prerequisites.sh --json [--require-tasks] [--include-tasks]" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

FEATURES_DIR="${REPO_ROOT}/.specify/features"

if [[ ! -d "${FEATURES_DIR}" ]]; then
  echo "Error: ${FEATURES_DIR} not found" >&2
  exit 1
fi

LATEST_FEATURE_DIR="$(find "${FEATURES_DIR}" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"

if [[ -z "${LATEST_FEATURE_DIR}" ]]; then
  echo "Error: no feature directories found under ${FEATURES_DIR}" >&2
  exit 1
fi

AVAILABLE_DOCS=()

if [[ -f "${LATEST_FEATURE_DIR}/plan.md" ]]; then
  AVAILABLE_DOCS+=("plan.md")
fi
if [[ -f "${LATEST_FEATURE_DIR}/spec.md" ]]; then
  AVAILABLE_DOCS+=("spec.md")
fi
if [[ -f "${LATEST_FEATURE_DIR}/data-model.md" ]]; then
  AVAILABLE_DOCS+=("data-model.md")
fi
if [[ -d "${LATEST_FEATURE_DIR}/contracts" ]]; then
  AVAILABLE_DOCS+=("contracts")
fi
if [[ -f "${LATEST_FEATURE_DIR}/research.md" ]]; then
  AVAILABLE_DOCS+=("research.md")
fi
if [[ -f "${LATEST_FEATURE_DIR}/quickstart.md" ]]; then
  AVAILABLE_DOCS+=("quickstart.md")
fi
if [[ -f "${LATEST_FEATURE_DIR}/tasks.md" ]]; then
  AVAILABLE_DOCS+=("tasks.md")
elif [[ "${REQUIRE_TASKS}" == "true" ]]; then
  echo "Error: tasks.md is required but not found in ${LATEST_FEATURE_DIR}" >&2
  exit 1
elif [[ "${INCLUDE_TASKS}" == "true" ]]; then
  AVAILABLE_DOCS+=("tasks.md (missing)")
fi

jq -n \
  --arg feature_dir "${LATEST_FEATURE_DIR}" \
  --argjson available_docs "$(printf '%s\n' "${AVAILABLE_DOCS[@]}" | jq -R . | jq -s .)" \
  '{feature_dir: $feature_dir, available_docs: $available_docs, source: "check-prerequisites.sh"}'

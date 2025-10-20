#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: create-new-feature.sh --json "<feature description>" --short-name "<short-name>"

Creates a new feature workspace under .specify/features, checks out a git branch,
and prints JSON containing the branch and spec file path.
EOF
  exit 1
}

FEATURE_JSON=""
SHORT_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      shift
      [[ $# -gt 0 ]] || usage
      FEATURE_JSON="$1"
      ;;
    --short-name)
      shift
      [[ $# -gt 0 ]] || usage
      SHORT_NAME="$1"
      ;;
    -h|--help)
      usage
      ;;
    *)
      usage
      ;;
  esac
  shift || true
done

[[ -n "$FEATURE_JSON" ]] || usage
[[ -n "$SHORT_NAME" ]] || usage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

if ! git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: script must run inside a git repository" >&2
  exit 1
fi

BRANCH_NAME="spec-${SHORT_NAME}"
if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
  echo "Error: branch ${BRANCH_NAME} already exists" >&2
  exit 1
fi

FEATURES_DIR="${REPO_ROOT}/.specify/features"
DATE_PREFIX="$(date +%Y%m%d)"
FEATURE_DIR="${FEATURES_DIR}/${DATE_PREFIX}-${SHORT_NAME}"
SPEC_FILE="${FEATURE_DIR}/spec.md"

mkdir -p "${FEATURE_DIR}"
mkdir -p "${FEATURE_DIR}/checklists"

if ! git -C "$REPO_ROOT" checkout -b "${BRANCH_NAME}"; then
  CURRENT_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
  echo "Warning: unable to create or switch to ${BRANCH_NAME}; continuing on ${CURRENT_BRANCH}" >&2
fi

if [[ ! -f "${SPEC_FILE}" ]]; then
  touch "${SPEC_FILE}"
fi

jq -n \
  --arg branch "${BRANCH_NAME}" \
  --arg spec "${SPEC_FILE}" \
  --arg feature_dir "${FEATURE_DIR}" \
  --arg short_name "${SHORT_NAME}" \
  '{branch_name: $branch, spec_file: $spec, feature_dir: $feature_dir, short_name: $short_name, source: "create-new-feature.sh"}'

#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: setup-plan.sh --json

Initializes implementation planning workspace for the most recent feature
specification and emits JSON with plan metadata.
EOF
  exit 1
}

if [[ $# -ne 1 || "$1" != "--json" ]]; then
  usage
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

FEATURES_DIR="${REPO_ROOT}/.specify/features"
TEMPLATE_PATH="${REPO_ROOT}/.specify/templates/plan-template.md"

if [[ ! -d "${FEATURES_DIR}" ]]; then
  echo "Error: ${FEATURES_DIR} not found" >&2
  exit 1
fi

if [[ ! -f "${TEMPLATE_PATH}" ]]; then
  echo "Error: plan template missing at ${TEMPLATE_PATH}" >&2
  exit 1
fi

LATEST_FEATURE_DIR="$(find "${FEATURES_DIR}" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"

if [[ -z "${LATEST_FEATURE_DIR}" ]]; then
  echo "Error: no feature directories found under ${FEATURES_DIR}" >&2
  exit 1
fi

FEATURE_SPEC="${LATEST_FEATURE_DIR}/spec.md"

if [[ ! -f "${FEATURE_SPEC}" ]]; then
  echo "Error: feature spec missing at ${FEATURE_SPEC}" >&2
  exit 1
fi

IMPL_PLAN="${LATEST_FEATURE_DIR}/plan.md"
QUICKSTART="${LATEST_FEATURE_DIR}/quickstart.md"
CONTRACTS_DIR="${LATEST_FEATURE_DIR}/contracts"

mkdir -p "${CONTRACTS_DIR}"

if [[ ! -f "${IMPL_PLAN}" ]]; then
  cp "${TEMPLATE_PATH}" "${IMPL_PLAN}"
fi

if [[ ! -f "${QUICKSTART}" ]]; then
  touch "${QUICKSTART}"
fi

FEATURE_BASENAME="$(basename "${LATEST_FEATURE_DIR}")"
SHORT_NAME="${FEATURE_BASENAME#*-}"
BRANCH_NAME="build-${SHORT_NAME}"

jq -n \
  --arg feature_spec "${FEATURE_SPEC}" \
  --arg impl_plan "${IMPL_PLAN}" \
  --arg specs_dir "${LATEST_FEATURE_DIR}" \
  --arg branch "${BRANCH_NAME}" \
  '{feature_spec: $feature_spec, impl_plan: $impl_plan, specs_dir: $specs_dir, branch: $branch, source: "setup-plan.sh"}'

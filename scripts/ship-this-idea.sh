#!/usr/bin/env bash
# Start the flagship Oh My Hermes product-build flow.

set -euo pipefail

IDEA="$*"
[ -n "$IDEA" ] || { echo "Usage: ship-this-idea.sh <idea>"; exit 2; }

if ! command -v hermes >/dev/null 2>&1; then
  echo "[ERROR] hermes not found"
  exit 1
fi

hermes -z "Ship this idea: $IDEA

Use Oh My Hermes. Ask at most three questions only if they materially change the
result. If the user does not answer, continue with recommended defaults. Produce
PRODUCT_BRIEF.md and DESIGN.md, build the smallest complete version, verify it,
deploy a preview if credentials are available, and report the live URL or the
single blocker."

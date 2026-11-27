#!/usr/bin/env bash
# Install-only smoke test; live profiles and kanban belong to verify.sh --setup.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/verify.sh" --install-only

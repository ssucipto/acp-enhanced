#!/usr/bin/env bash
# Phase 1 fixture: SH-01 pass
set -euo pipefail
trap 'echo "Error at line $LINENO" >&2; exit 3' ERR
echo "ok"

#!/usr/bin/env bash
set -euo pipefail
trap 'echo "fail" >&2; exit 1' ERR

echo "ok"

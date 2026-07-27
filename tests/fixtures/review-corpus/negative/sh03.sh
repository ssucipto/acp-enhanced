#!/usr/bin/env bash
set -euo pipefail
trap 'echo "fail" >&2; exit 1' ERR

target="${1:-*.txt}"
cp "$target" /tmp/out

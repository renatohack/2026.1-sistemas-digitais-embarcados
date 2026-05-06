#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "uso: $0 <binario> [args...]" >&2
    exit 2
fi

binary="$1"
shift

if [[ "$(uname -m)" == "aarch64" ]]; then
    exec "$binary" "$@"
fi

exec qemu-aarch64 -L "${QEMU_LD_PREFIX:-/usr/aarch64-linux-gnu}" "$binary" "$@"

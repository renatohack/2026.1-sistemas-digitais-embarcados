#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${repo_root}/build/dr4_at"
evidence="${repo_root}/evidencias/gdb_registers.txt"
port="${AT_GDB_PORT:-23457}"

mkdir -p "${repo_root}/evidencias"

qemu-aarch64 -g "${port}" "${target}" >/tmp/dr4_at_gdb_qemu.out 2>/tmp/dr4_at_gdb_qemu.err &
qemu_pid=$!

cleanup() {
  if kill -0 "${qemu_pid}" >/dev/null 2>&1; then
    kill "${qemu_pid}" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

sleep 0.3

gdb-multiarch -q -batch \
  -ex "set architecture aarch64" \
  -ex "file ${target}" \
  -ex "target remote :${port}" \
  -ex "break metrics_done" \
  -ex "break lut_done" \
  -ex "break neon_int_done" \
  -ex "break neon_float_done" \
  -ex "continue" \
  -ex "printf \"\\n[metrics_done]\\n\"" \
  -ex "info registers x0 x1 x2 x3 x4 x5 x6" \
  -ex "continue" \
  -ex "printf \"\\n[lut_done]\\n\"" \
  -ex "info registers x0 x1" \
  -ex "x/7dw &lut_output_values" \
  -ex "continue" \
  -ex "printf \"\\n[neon_int_done]\\n\"" \
  -ex "info registers x0" \
  -ex "p/x \$v0" \
  -ex "continue" \
  -ex "printf \"\\n[neon_float_done]\\n\"" \
  -ex "p/x \$v2" \
  -ex "x/4fw &normalized_values" \
  -ex "detach" \
  -ex "quit" | tee "${evidence}"

wait "${qemu_pid}" || true

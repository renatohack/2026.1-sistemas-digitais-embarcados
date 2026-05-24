#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${repo_root}/build/tp3_neon_macros"
evidence="${repo_root}/evidencias/gdb_registers.txt"
port="${TP3_GDB_PORT:-23456}"

mkdir -p "${repo_root}/evidencias"

qemu-aarch64 -g "${port}" "${target}" >/tmp/tp3_gdb_qemu.out 2>/tmp/tp3_gdb_qemu.err &
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
  -ex "break ex1_after_insert" \
  -ex "break ex2_after_insert" \
  -ex "break ex5_after_shuffle" \
  -ex "break ex9_after_reduce" \
  -ex "break ex11_after_first_zero" \
  -ex "continue" \
  -ex "printf \"\\n[ex1_after_insert]\\n\"" \
  -ex "p/x \$v0" \
  -ex "continue" \
  -ex "printf \"\\n[ex2_after_insert]\\n\"" \
  -ex "p/x \$v0" \
  -ex "continue" \
  -ex "printf \"\\n[ex5_after_shuffle]\\n\"" \
  -ex "p/x \$v2" \
  -ex "continue" \
  -ex "printf \"\\n[ex9_after_reduce]\\n\"" \
  -ex "p/x \$w0" \
  -ex "p/x \$v2" \
  -ex "continue" \
  -ex "printf \"\\n[ex11_after_first_zero]\\n\"" \
  -ex "p/x \$v0" \
  -ex "detach" \
  -ex "quit" | tee "${evidence}"

wait "${qemu_pid}" || true

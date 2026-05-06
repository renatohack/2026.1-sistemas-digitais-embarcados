#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
binary="${repo_root}/build/bin/ex7_mp_sub_128"
gdb_script="${repo_root}/scripts/gdb/qemu_ex7_borrow.gdb"

mkdir -p "${repo_root}/evidence/qemu/ex04" "${repo_root}/evidence/qemu/ex07"

qemu-aarch64 -g 1234 -L "${QEMU_LD_PREFIX:-/usr/aarch64-linux-gnu}" "${binary}" borrow >/dev/null 2>&1 &
qemu_pid=$!
trap 'kill "${qemu_pid}" 2>/dev/null || true' EXIT

sleep 0.2
gdb-multiarch -q "${binary}" -x "${gdb_script}" >/dev/null 2>&1
wait "${qemu_pid}"
cp "${repo_root}/evidence/qemu/ex04/gdb_mp_sub_128_borrow.txt" "${repo_root}/evidence/qemu/ex07/gdb_mp_sub_128_borrow.txt"

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
binary="${repo_root}/build/bin/ex7_mp_sub_128"
gdb_script="${repo_root}/scripts/gdb/native_ex7_borrow.gdb"

mkdir -p "${repo_root}/evidence/raspberry/ex04" "${repo_root}/evidence/raspberry/ex07"

gdb -q "${binary}" -x "${gdb_script}" >/dev/null 2>&1
cp "${repo_root}/evidence/raspberry/ex04/gdb_mp_sub_128_borrow.txt" "${repo_root}/evidence/raspberry/ex07/gdb_mp_sub_128_borrow.txt"

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
runner="${repo_root}/scripts/run_binary.sh"
bin_dir="${repo_root}/build/bin"

tests=(
    ex2_soc_addrs
    ex6_mp_add_192
    ex7_mp_sub_128
    ex8_u64_to_str
    ex9_parse_i64
    ex10_int_div_to_double
    ex11_parse_i64_range
    tp1_driver
)

for test_bin in "${tests[@]}"; do
    printf '===== %s =====\n' "${test_bin}"
    "${runner}" "${bin_dir}/${test_bin}"
    printf '\n'
done

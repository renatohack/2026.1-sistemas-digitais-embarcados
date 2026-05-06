#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
bin_dir="${repo_root}/build/bin"

mkdir -p \
    "${repo_root}/evidence/raspberry/ex02" \
    "${repo_root}/evidence/raspberry/ex03" \
    "${repo_root}/evidence/raspberry/ex04" \
    "${repo_root}/evidence/raspberry/ex05" \
    "${repo_root}/evidence/raspberry/ex06" \
    "${repo_root}/evidence/raspberry/ex07" \
    "${repo_root}/evidence/raspberry/ex08" \
    "${repo_root}/evidence/raspberry/ex09" \
    "${repo_root}/evidence/raspberry/ex10" \
    "${repo_root}/evidence/raspberry/ex11" \
    "${repo_root}/evidence/raspberry/ex12"

make -C "${repo_root}" clean >"${repo_root}/evidence/raspberry/ex03/make_clean.txt" 2>&1
make -C "${repo_root}" >"${repo_root}/evidence/raspberry/ex03/make_build.txt" 2>&1

"${bin_dir}/ex2_soc_addrs" >"${repo_root}/evidence/raspberry/ex02/ex2_soc_addrs_output.txt"
"${bin_dir}/ex6_mp_add_192" >"${repo_root}/evidence/raspberry/ex06/ex6_mp_add_192_output.txt"
"${bin_dir}/ex7_mp_sub_128" >"${repo_root}/evidence/raspberry/ex07/ex7_mp_sub_128_output.txt"
"${bin_dir}/ex8_u64_to_str" >"${repo_root}/evidence/raspberry/ex08/ex8_u64_to_str_output.txt"
"${bin_dir}/ex9_parse_i64" >"${repo_root}/evidence/raspberry/ex09/ex9_parse_i64_output.txt"
"${bin_dir}/ex10_int_div_to_double" >"${repo_root}/evidence/raspberry/ex10/ex10_int_div_to_double_output.txt"
"${bin_dir}/ex11_parse_i64_range" >"${repo_root}/evidence/raspberry/ex11/ex11_parse_i64_range_output.txt"
"${bin_dir}/tp1_driver" >"${repo_root}/evidence/raspberry/ex12/ex12_driver_output.txt"

"${repo_root}/scripts/run_test_suite.sh" >"${repo_root}/evidence/raspberry/ex12/full_test_suite_output.txt"

objdump -d "${bin_dir}/ex2_soc_addrs" >"${repo_root}/evidence/raspberry/ex02/ex2_soc_addrs_objdump.txt"
objdump -d "${bin_dir}/tp1_driver" >"${repo_root}/evidence/raspberry/ex05/tp1_driver_objdump.txt"
objdump -t "${bin_dir}/tp1_driver" >"${repo_root}/evidence/raspberry/ex12/tp1_driver_symbols.txt"

"${repo_root}/scripts/raspberry/run_native_gdb_ex7.sh"

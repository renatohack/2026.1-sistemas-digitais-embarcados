#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
deliver_dir="${repo_root}/ENTREGAVEL"
report_pdf="${repo_root}/docs/report/RELATORIO_TP1_Renato_Noronha_Hack.pdf"

if [[ ! -f "${report_pdf}" ]]; then
  echo "PDF nao encontrado. Gere primeiro com ./scripts/generate_report_pdf.sh" >&2
  exit 1
fi

mkdir -p "${deliver_dir}"

cp -f "${repo_root}/Makefile" "${deliver_dir}/"
cp -f "${repo_root}/README.md" "${deliver_dir}/"
cp -f "${repo_root}/Enunciado TP1.html" "${deliver_dir}/"
cp -f "${report_pdf}" "${deliver_dir}/"

mkdir -p "${deliver_dir}/build"
cp -rf "${repo_root}/build/bin" "${deliver_dir}/build/"

cp -rf "${repo_root}/docs" "${deliver_dir}/"
cp -rf "${repo_root}/evidence" "${deliver_dir}/"
cp -rf "${repo_root}/include" "${deliver_dir}/"
cp -rf "${repo_root}/scripts" "${deliver_dir}/"
cp -rf "${repo_root}/src" "${deliver_dir}/"

printf 'Pasta ENTREGAVEL criada em: %s\n' "${deliver_dir}"

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
report_md="${repo_root}/docs/report/relatorio_tp1.md"
report_pdf="${repo_root}/docs/report/RELATORIO_TP1_Renato_Noronha_Hack.pdf"
header_tex="${repo_root}/docs/report/pandoc-header.tex"

pandoc \
  "${report_md}" \
  --from markdown+raw_tex \
  --to pdf \
  --pdf-engine=pdflatex \
  --toc \
  --number-sections \
  --highlight-style=tango \
  -H "${header_tex}" \
  -V papersize:a4 \
  -V geometry:margin=2.4cm \
  -V fontsize:11pt \
  -o "${report_pdf}"

printf 'PDF gerado em: %s\n' "${report_pdf}"

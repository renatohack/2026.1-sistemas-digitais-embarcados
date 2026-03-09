#!/usr/bin/env bash
set -euo pipefail

if ! command -v iverilog >/dev/null 2>&1; then
  echo "Erro: iverilog nao encontrado no PATH."
  echo "Instale iverilog e tente novamente."
  exit 1
fi

if ! command -v vvp >/dev/null 2>&1; then
  echo "Erro: vvp nao encontrado no PATH."
  echo "Instale iverilog completo (com vvp) e tente novamente."
  exit 1
fi

mkdir -p sim_out

echo "[1/4] TB Comb_Logic"
iverilog -g2012 -o sim_out/tb_comb_logic.out src/comb_logic.v tb/tb_comb_logic.v
vvp sim_out/tb_comb_logic.out | tee sim_out/tb_comb_logic.log

echo "[2/4] TB Mux2to1"
iverilog -g2012 -o sim_out/tb_mux2to1.out src/mux2to1.v tb/tb_mux2to1.v
vvp sim_out/tb_mux2to1.out | tee sim_out/tb_mux2to1.log

echo "[3/4] TB Reg1"
iverilog -g2012 -o sim_out/tb_reg1.out src/reg1.v tb/tb_reg1.v
vvp sim_out/tb_reg1.out | tee sim_out/tb_reg1.log

echo "[4/4] TB Counter2bit"
iverilog -g2012 -o sim_out/tb_counter2bit.out src/reg1.v src/counter2bit.v tb/tb_counter2bit.v
vvp sim_out/tb_counter2bit.out | tee sim_out/tb_counter2bit.log

echo "Simulacoes concluidas. Logs salvos em sim_out/*.log"

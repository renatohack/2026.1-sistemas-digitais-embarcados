#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/sim/build"
LOG_DIR="$ROOT_DIR/evidencias/simulacao"

mkdir -p "$BUILD_DIR" "$LOG_DIR"

SOURCES=(
  "$ROOT_DIR/gowin/src/int_unsigned_alu.v"
  "$ROOT_DIR/gowin/src/int_signed_alu.v"
  "$ROOT_DIR/gowin/src/fixed_q3_4_alu.v"
  "$ROOT_DIR/gowin/src/minifloat_e4m3_addsub.v"
  "$ROOT_DIR/gowin/src/arithmetic_core.v"
  "$ROOT_DIR/gowin/src/tp3_demo_vectors.v"
  "$ROOT_DIR/gowin/src/button_conditioner.v"
  "$ROOT_DIR/gowin/src/uart_tx.v"
  "$ROOT_DIR/gowin/src/tp3_demo_top.v"
)

TESTS=(
  tb_int_unsigned_alu
  tb_int_signed_alu
  tb_fixed_q3_4_alu
  tb_minifloat_e4m3_addsub
  tb_arithmetic_core
  tb_tp3_demo_top
)

cd "$ROOT_DIR"

for test_name in "${TESTS[@]}"; do
  echo "==> $test_name"
  iverilog -g2012 -Wall -o "$BUILD_DIR/$test_name.vvp" "${SOURCES[@]}" "$ROOT_DIR/sim/$test_name.v"
  vvp "$BUILD_DIR/$test_name.vvp" | tee "$LOG_DIR/$test_name.log"
  cp "$BUILD_DIR/$test_name.vcd" "$LOG_DIR/$test_name.vcd"
done

echo "All simulations completed."

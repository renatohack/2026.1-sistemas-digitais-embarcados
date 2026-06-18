SHELL := /bin/bash

IVERILOG ?= iverilog
VVP ?= vvp
GTKWAVE ?= gtkwave

RTL := $(wildcard src/rtl/*.v)
TESTS := tb_sample_generator tb_signal_monitor_core tb_extreme_metrics tb_bram tb_uart_results tb_pll_54mhz tb_button_debounce

.PHONY: all sim clean wave-core wave-fsm wave-bram wave-metrics wave-uart wave-pll list

all: sim

sim: $(addprefix build/sim/,$(TESTS))
	@mkdir -p build/waves
	@set -e; for test in $(TESTS); do \
		echo "==> $$test"; \
		$(VVP) build/sim/$$test; \
	done

build/sim/%: tb/%.v $(RTL)
	@mkdir -p build/sim build/waves
	$(IVERILOG) -g2005 -Wall -DSIM -I src/rtl -o $@ $< $(RTL)

wave-core: build/waves/tb_signal_monitor_core.vcd
	$(GTKWAVE) gtkwave/dr3_core.gtkw

wave-fsm: build/waves/tb_signal_monitor_core.vcd
	$(GTKWAVE) gtkwave/dr3_fsm.gtkw

wave-bram: build/waves/tb_signal_monitor_core.vcd
	$(GTKWAVE) gtkwave/dr3_bram.gtkw

wave-metrics: build/waves/tb_signal_monitor_core.vcd
	$(GTKWAVE) gtkwave/dr3_metrics.gtkw

wave-uart: build/waves/tb_uart_results.vcd
	$(GTKWAVE) gtkwave/dr3_uart.gtkw

wave-pll: build/waves/tb_pll_54mhz.vcd
	$(GTKWAVE) gtkwave/dr3_pll.gtkw

build/waves/tb_signal_monitor_core.vcd: build/sim/tb_signal_monitor_core
	$(VVP) build/sim/tb_signal_monitor_core

build/waves/tb_uart_results.vcd: build/sim/tb_uart_results
	$(VVP) build/sim/tb_uart_results

build/waves/tb_pll_54mhz.vcd: build/sim/tb_pll_54mhz
	$(VVP) build/sim/tb_pll_54mhz

list:
	@printf '%s\n' $(TESTS)

clean:
	rm -rf build

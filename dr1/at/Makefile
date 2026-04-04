.PHONY: sim sim-core sim-board wave wave-board clean

SIM_CORE_OUT := build/access_control_tb.vvp
SIM_BOARD_OUT := build/access_control_tang_nano_9k_top_tb.vvp

VCD_CORE_OUT := sim/vcd/access_control.vcd
FST_CORE_OUT := sim/fst/access_control.fst
GTKW_CORE_FILE := sim/gtkwave/access_control.gtkw

VCD_BOARD_OUT := sim/vcd/access_control_tang_nano_9k_top.vcd
FST_BOARD_OUT := sim/fst/access_control_tang_nano_9k_top.fst
GTKW_BOARD_FILE := sim/gtkwave/access_control_tang_nano_9k_top.gtkw

sim: sim-core sim-board

sim-core:
	mkdir -p build sim/vcd sim/fst
	iverilog -g2012 -Wall -o $(SIM_CORE_OUT) rtl/code_validator.v rtl/access_control.v tb/access_control_tb.v
	vvp $(SIM_CORE_OUT)
	vcd2fst $(VCD_CORE_OUT) $(FST_CORE_OUT)

sim-board:
	mkdir -p build sim/vcd sim/fst
	iverilog -g2012 -Wall -o $(SIM_BOARD_OUT) rtl/code_validator.v rtl/access_control.v rtl/button_debouncer.v gowin/src/access_control_tang_nano_9k_top.v tb/access_control_tang_nano_9k_top_tb.v
	vvp $(SIM_BOARD_OUT)
	vcd2fst $(VCD_BOARD_OUT) $(FST_BOARD_OUT)

wave: sim-core
	gtkwave -f $(FST_CORE_OUT) $(GTKW_CORE_FILE)

wave-board: sim-board
	gtkwave -f $(FST_BOARD_OUT) $(GTKW_BOARD_FILE)

clean:
	rm -f $(SIM_CORE_OUT) $(SIM_BOARD_OUT) $(VCD_CORE_OUT) $(FST_CORE_OUT) $(VCD_BOARD_OUT) $(FST_BOARD_OUT)

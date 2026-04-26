HOST_ARCH := $(shell uname -m)

ifeq ($(HOST_ARCH),aarch64)
CROSS ?=
GDB ?= gdb
else
CROSS ?= aarch64-linux-gnu-
GDB ?= gdb-multiarch
endif

CC := $(CROSS)gcc
OBJDUMP := $(CROSS)objdump
RUNNER := ./scripts/run_binary.sh

CFLAGS := -Wall -Wextra -Werror -std=c11 -O0 -g -fno-omit-frame-pointer -fno-pie -Iinclude
ASFLAGS := -g -fno-pie
LDFLAGS := -no-pie
LDLIBS := -lm

OBJDIR := build/obj
BINDIR := build/bin

COMMON_C_SRCS := src/c/test_common.c
COMMON_OBJS := $(patsubst src/c/%.c,$(OBJDIR)/c/%.o,$(COMMON_C_SRCS))

ASM_SRCS := \
	src/asm/soc_addrs.s \
	src/asm/mp_add_192.s \
	src/asm/mp_sub_128.s \
	src/asm/u64_to_str.s \
	src/asm/parse_i64.s \
	src/asm/int_div_to_double.s \
	src/asm/parse_i64_range.s

ASM_OBJS := $(patsubst src/asm/%.s,$(OBJDIR)/asm/%.o,$(ASM_SRCS))

BIN_EX2 := $(BINDIR)/ex2_soc_addrs
BIN_EX6 := $(BINDIR)/ex6_mp_add_192
BIN_EX7 := $(BINDIR)/ex7_mp_sub_128
BIN_EX8 := $(BINDIR)/ex8_u64_to_str
BIN_EX9 := $(BINDIR)/ex9_parse_i64
BIN_EX10 := $(BINDIR)/ex10_int_div_to_double
BIN_EX11 := $(BINDIR)/ex11_parse_i64_range
BIN_EX12 := $(BINDIR)/tp1_driver

ALL_BINS := \
	$(BIN_EX2) \
	$(BIN_EX6) \
	$(BIN_EX7) \
	$(BIN_EX8) \
	$(BIN_EX9) \
	$(BIN_EX10) \
	$(BIN_EX11) \
	$(BIN_EX12)

.PHONY: all clean run test objdump help

all: $(ALL_BINS)

$(OBJDIR)/c/%.o: src/c/%.c include/tp1.h
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/asm/%.o: src/asm/%.s
	@mkdir -p $(@D)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BIN_EX2): $(OBJDIR)/c/test_soc_addrs.o $(COMMON_OBJS) $(OBJDIR)/asm/soc_addrs.o
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_EX6): $(OBJDIR)/c/test_mp_add_192.o $(COMMON_OBJS) $(OBJDIR)/asm/mp_add_192.o
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_EX7): $(OBJDIR)/c/test_mp_sub_128.o $(COMMON_OBJS) $(OBJDIR)/asm/mp_sub_128.o
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_EX8): $(OBJDIR)/c/test_u64_to_str.o $(COMMON_OBJS) $(OBJDIR)/asm/u64_to_str.o
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_EX9): $(OBJDIR)/c/test_parse_i64.o $(COMMON_OBJS) $(OBJDIR)/asm/parse_i64.o
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_EX10): $(OBJDIR)/c/test_int_div_to_double.o $(COMMON_OBJS) $(OBJDIR)/asm/int_div_to_double.o
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_EX11): $(OBJDIR)/c/test_parse_i64_range.o $(COMMON_OBJS) $(OBJDIR)/asm/parse_i64_range.o $(OBJDIR)/asm/parse_i64.o
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_EX12): $(OBJDIR)/c/tp1_driver.o $(COMMON_OBJS) $(OBJDIR)/asm/mp_add_192.o $(OBJDIR)/asm/u64_to_str.o $(OBJDIR)/asm/parse_i64.o $(OBJDIR)/asm/int_div_to_double.o $(OBJDIR)/asm/parse_i64_range.o
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

run: $(BIN_EX12)
	$(RUNNER) $(BIN_EX12)

test: all
	./scripts/run_test_suite.sh

objdump: $(BIN_EX12)
	$(OBJDUMP) -d $(BIN_EX12)

clean:
	rm -rf build

help:
	@printf '%s\n' \
		'alvos disponiveis:' \
		'  make        - compila todos os executaveis do TP1' \
		'  make run    - executa o driver final (Ex12)' \
		'  make test   - executa todos os executaveis de validacao' \
		'  make objdump- mostra o objdump do driver final' \
		'  make clean  - remove a pasta build'

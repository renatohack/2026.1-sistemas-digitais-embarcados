PROJECT := tp3_neon_macros
BUILD_DIR := build
SRC_DIR := src
TEST_DIR := tests
INCLUDE_DIR := include
REPORT_DIR := relatorios
EVIDENCE_DIR := evidencias
SCRIPT_DIR := scripts

CROSS ?= aarch64-linux-gnu
CC := $(CROSS)-gcc
OBJDUMP := $(CROSS)-objdump
ASFLAGS := -Wall -Wextra -O2 -g -I$(INCLUDE_DIR)
CFLAGS := -Wall -Wextra -O2 -g -std=c11 -I$(INCLUDE_DIR)
LDFLAGS := -static

TARGET := $(BUILD_DIR)/$(PROJECT)
OBJS := \
	$(BUILD_DIR)/tp3_exercises.o \
	$(BUILD_DIR)/test_tp3.o

.PHONY: all clean test evidence objdump-evidence gdb-evidence report dirs

all: $(TARGET)

dirs:
	mkdir -p $(BUILD_DIR) $(EVIDENCE_DIR) $(REPORT_DIR)

$(BUILD_DIR)/tp3_exercises.o: $(SRC_DIR)/tp3_exercises.S | dirs
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/test_tp3.o: $(TEST_DIR)/test_tp3.c $(INCLUDE_DIR)/tp3.h | dirs
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@

test: $(TARGET)
	qemu-aarch64 $(TARGET)

evidence: $(TARGET) objdump-evidence
	qemu-aarch64 $(TARGET) | tee $(EVIDENCE_DIR)/qemu_test_output.txt
	file $(TARGET) | tee $(EVIDENCE_DIR)/binario_info.txt
	printf 'make\nmake test\nmake evidence\nmake gdb-evidence\nmake report\n' > $(EVIDENCE_DIR)/comandos_reproducao.txt

objdump-evidence: $(TARGET)
	$(OBJDUMP) -d $(BUILD_DIR)/tp3_exercises.o > $(EVIDENCE_DIR)/objdump_tp3_exercises.txt
	$(OBJDUMP) -d $(TARGET) > $(EVIDENCE_DIR)/objdump_tp3_binary.txt

gdb-evidence: $(TARGET)
	./$(SCRIPT_DIR)/capture_gdb_registers.sh

report: $(REPORT_DIR)/relatorio_DR4_TP3.pdf

$(REPORT_DIR)/relatorio_DR4_TP3.pdf: $(REPORT_DIR)/relatorio_DR4_TP3.html
	wkhtmltopdf --enable-local-file-access $< $@

clean:
	rm -rf $(BUILD_DIR)

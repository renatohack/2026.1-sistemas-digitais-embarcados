PROJECT := dr4_at
BUILD_DIR := build
SRC_DIR := src
EVIDENCE_DIR := evidencias
REPORT_DIR := relatorios
SCRIPT_DIR := scripts
TEST_DIR := tests

CROSS ?= aarch64-linux-gnu
AS := $(CROSS)-as
LD := $(CROSS)-ld
OBJDUMP := $(CROSS)-objdump
READELF := $(CROSS)-readelf

ASFLAGS := -g -I$(SRC_DIR)
LDFLAGS := -static

TARGET := $(BUILD_DIR)/$(PROJECT)
OBJS := \
	$(BUILD_DIR)/main.o \
	$(BUILD_DIR)/processamento.o \
	$(BUILD_DIR)/conversao.o

.PHONY: all clean test evidence objdump-evidence gdb-evidence report dirs

all: $(TARGET)

dirs:
	mkdir -p $(BUILD_DIR) $(EVIDENCE_DIR) $(REPORT_DIR)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s | dirs
	$(AS) $(ASFLAGS) $< -o $@

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

test: $(TARGET)
	qemu-aarch64 $(TARGET) > $(BUILD_DIR)/qemu_output.txt
	diff -u $(TEST_DIR)/expected_output.txt $(BUILD_DIR)/qemu_output.txt
	qemu-aarch64 $(TARGET)

evidence: $(TARGET) objdump-evidence
	qemu-aarch64 $(TARGET) | tee $(EVIDENCE_DIR)/qemu_output.txt
	file $(TARGET) | tee $(EVIDENCE_DIR)/binario_info.txt
	$(READELF) -S -s $(TARGET) > $(EVIDENCE_DIR)/readelf_sections_symbols.txt
	printf 'make\nmake test\nmake evidence\nmake gdb-evidence\nmake report\n' > $(EVIDENCE_DIR)/comandos_reproducao.txt

objdump-evidence: $(TARGET)
	$(OBJDUMP) -h -t -d $(TARGET) > $(EVIDENCE_DIR)/objdump_full.txt
	$(OBJDUMP) -d $(BUILD_DIR)/processamento.o > $(EVIDENCE_DIR)/objdump_processamento.txt
	$(OBJDUMP) -d $(BUILD_DIR)/main.o > $(EVIDENCE_DIR)/objdump_main.txt

gdb-evidence: $(TARGET)
	./$(SCRIPT_DIR)/capture_gdb.sh

report: $(REPORT_DIR)/relatorio_DR4_AT.pdf

$(REPORT_DIR)/relatorio_DR4_AT.pdf: $(REPORT_DIR)/relatorio_DR4_AT.html
	wkhtmltopdf --enable-local-file-access $< $@

clean:
	rm -rf $(BUILD_DIR)

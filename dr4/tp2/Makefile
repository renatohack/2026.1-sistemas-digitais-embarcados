PROJECT := tp2_arm64_bits
BUILD_DIR := build
SRC_DIR := src
TEST_DIR := tests
INCLUDE_DIR := include
REPORT_DIR := relatorios
EVIDENCE_DIR := evidencias

CROSS ?= aarch64-linux-gnu
CC := $(CROSS)-gcc
ASFLAGS := -Wall -Wextra -O2 -g -I$(INCLUDE_DIR)
CFLAGS := -Wall -Wextra -O2 -g -std=c11 -I$(INCLUDE_DIR)
LDFLAGS := -static

TARGET := $(BUILD_DIR)/$(PROJECT)
OBJS := \
	$(BUILD_DIR)/tp2_exercises.o \
	$(BUILD_DIR)/test_tp2.o

.PHONY: all clean test evidence dirs

all: $(TARGET)

dirs:
	mkdir -p $(BUILD_DIR) $(EVIDENCE_DIR) $(REPORT_DIR)

$(BUILD_DIR)/tp2_exercises.o: $(SRC_DIR)/tp2_exercises.S | dirs
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/test_tp2.o: $(TEST_DIR)/test_tp2.c $(INCLUDE_DIR)/tp2.h | dirs
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@

test: $(TARGET)
	qemu-aarch64 $(TARGET)

evidence: $(TARGET)
	qemu-aarch64 $(TARGET) | tee $(EVIDENCE_DIR)/qemu_test_output.txt

clean:
	rm -rf $(BUILD_DIR)

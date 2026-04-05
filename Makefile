C3C      := c3c
AS       := riscv32-elf-as
LD       := riscv32-elf-ld
OBJCOPY  := riscv32-elf-objcopy
ESPTOOL  := esptool

TARGET   := blink
SRC_C3   := main.c3
LDSCRIPT := esp32c3.ld
PORT     := /dev/ttyACM0
BAUD     := 921600
RAM_BAUD := 460800

BUILD    := build

OBJ_C3   := $(BUILD)/blink.o
ELF      := $(BUILD)/$(TARGET).elf
BIN      := $(BUILD)/$(TARGET).bin

C3FLAGS  := --target elf-riscv32 \
            --riscv-cpu=rvimac \
            --riscv-abi=int-only \
            --reloc=none \
            --memory-env=none \
            --use-stdlib=no \
            --link-libc=no \
            --no-entry

ASFLAGS  := -march=rv32imc
LDFLAGS  := -T $(LDSCRIPT) --gc-sections

.PHONY: all erase flash load-ram

all: $(BIN)

$(OBJ_C3): $(SRC_C3) | $(BUILD)
	$(C3C) compile-only $(C3FLAGS) --obj-out $(BUILD)/ $(SRC_C3)

$(ELF): $(OBJ_C3)
	$(LD) $(LDFLAGS) $(OBJ_C3) -o $(ELF)

$(BIN): $(ELF)
	$(ESPTOOL) --chip esp32c3 elf2image $(ELF) -o $(BIN)

erase:
	$(ESPTOOL) --chip esp32c3 --port $(PORT) erase-flash

flash: $(BIN)
	$(ESPTOOL) --chip esp32c3 --port $(PORT) --baud $(BAUD) \
	    write-flash 0x0 $(BIN)

load-ram: $(BIN)
	$(ESPTOOL) --chip esp32c3 --port $(PORT) --baud $(RAM_BAUD) \
	    --no-stub load-ram $(BIN)
$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)

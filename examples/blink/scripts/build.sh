#!/usr/bin/env bash
set -eu

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$project_dir/build"
rm -f "$project_dir"/build/*.o "$project_dir"/build/*.elf "$project_dir"/build/*.bin

c3c compile-only \
    --target elf-riscv32 \
    --riscv-cpu=rvimac \
    --riscv-abi=int-only \
    --reloc=none \
    --memory-env=none \
    --use-stdlib=no \
    --link-libc=no \
    --no-entry \
    --obj-out "$project_dir/build/" \
    "$project_dir/src/main.c3" \
    "$project_dir/../../espc3.c3" \
    "$project_dir/../../espc3.c3i"

riscv32-elf-ld \
    -T "$project_dir/esp32c3.ld" \
    --gc-sections \
    "$project_dir/build/blink.o" \
    "$project_dir/build/espc3.o" \
    -o "$project_dir/build/blink.elf"

esptool --chip esp32c3 elf2image \
    "$project_dir/build/blink.elf" \
    -o "$project_dir/build/blink.bin"

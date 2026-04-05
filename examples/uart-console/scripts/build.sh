#!/usr/bin/env bash
set -eu

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$project_dir/build"
rm -f "$project_dir"/build/*.o "$project_dir"/build/*.elf "$project_dir"/build/*.bin

c3c build uart_console --path "$project_dir"

esptool --chip esp32c3 elf2image \
    --flash-mode dio \
    --flash-freq 40m \
    --flash-size 4MB \
    "$project_dir/build/uart_console.elf" \
    -o "$project_dir/build/uart_console.bin"

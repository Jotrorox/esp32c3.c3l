#!/usr/bin/env bash
set -eu

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

esptool --chip esp32c3 elf2image \
    "$project_dir/build/blink.elf" \
    -o "$project_dir/build/blink.bin"

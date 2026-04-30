#!/usr/bin/env bash
set -eu

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
port="${1:-/dev/ttyACM0}"

esptool --chip esp32c3 \
    --port "$port" \
    --baud 460800 \
    write_flash \
    --flash-mode dio \
    --flash-freq 40m \
    --flash-size 4MB \
    0x0 "$project_dir/build/button-input.bin"

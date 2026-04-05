#!/usr/bin/env bash
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "usage: $0 <serial-port> [baud]" >&2
    exit 1
fi

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
port="$1"
baud="${2:-460800}"

esptool --chip esp32c3 --port "$port" --baud "$baud" \
    --before default-reset --after hard-reset \
    write-flash 0x0 "$project_dir/build/blink.bin"

`esp32c3` is a minimal ESP32-C3 C3 library.

It currently exposes:

- `pin_out(pin)`
- `pin_on(pin)`
- `pin_off(pin)`
- `uart_write(text)`
- `uart_write_line(text)`
- `delay_us(us)`
- `delay_ms(ms)`

Available pin constants:

- `PIN0` through `PIN10`
- `PIN18` through `PIN21`

The UART helpers write through the ESP32-C3 ROM console transmit path, so output follows the active board console without duplicating characters.

You also need: 
1. `c3c`
2. `esptool`

### Examples

Build:

```sh
cd examples/blink # Or cd examples/uart-console
./scripts/build.sh
```

Load to RAM:

```sh
./scripts/load-ram.sh /dev/ttyACM0
```

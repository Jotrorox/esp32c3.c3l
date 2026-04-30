`esp32c3` is a minimal ESP32-C3 C3 library.

It currently exposes:

- `init()`
- `pin_out(pin)`
- `pin_on(pin)`
- `pin_off(pin)`
- `pin_in(pin)`
- `pin_in_pullup(pin)`
- `pin_in_pulldown(pin)`
- `pin_read(pin)`
- `uart_write(text)`
- `uart_write_line(text)`
- `delay_us(us)`
- `delay_ms(ms)`

Available pin constants:

- `PIN0` through `PIN10`
- `PIN18` through `PIN21`

The UART helpers write through the ESP32-C3 ROM console transmit path, so output follows the active board console without duplicating characters.
Call `init()` at the top of `main()` when booting from flash so the library can initialize the ROM boot watchdog handling before entering the main loop.

You also need: 
1. `c3c`
2. `esptool`

### Examples

Build:

```sh
cd examples/blink        # Or cd examples/uart-console
# Or cd examples/button-input
./scripts/build.sh
```

Flash to storage and boot from flash:

```sh
./scripts/flash.sh /dev/ttyACM0
```

`esp32c3` is a minimal ESP32-C3 C3 library.

It currently exposes:

- `print(text)` – write text to UART
- `println(text)` – write text + newline to UART
- `delay_us(us)`
- `delay_ms(ms)`

### GPIO HAL (`esp32c3::hal::gpio`)

- `gpio::mode(pin, mode)` – configure a pin (`mode`: `INPUT`, `INPUT_PULLUP`, `INPUT_PULLDOWN`, `OUTPUT`)
- `gpio::write(pin, value)` – set pin high (`true`) or low (`false`)
- `gpio::read(pin)` – read pin level (`bool`)

Available pin constants:

- `PIN0` through `PIN10`
- `PIN18` through `PIN21`

The UART helpers write through the ESP32-C3 ROM console transmit path, so output follows the active board console without duplicating characters.
The timer used by `delay_us`/`delay_ms` is initialized automatically on first use — no setup call is required.

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

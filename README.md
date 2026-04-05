`esp32c3` is a minimal ESP32-C3 C3 library.

It currently exposes:

- `pin_out(pin)`
- `pin_on(pin)`
- `pin_off(pin)`

Available pin constants:

- `PIN0` through `PIN10`
- `PIN18` through `PIN21`

## Blink example

You also need: 
1. `c3c`
2. `esptool`

Build:

```sh
cd examples/blink
./scripts/build.sh
```

Load to RAM:

```sh
./scripts/load-ram.sh /dev/ttyACM0
```

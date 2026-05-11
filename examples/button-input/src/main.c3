module button_input;

import esp32::hal::gpio;
import esp32;

fn void main() @export("start")
{
    gpio::mode(PIN8, OUTPUT);
    gpio::mode(PIN9, INPUT_PULLUP);

    while (true)
    {
        gpio::write(PIN8, !gpio::read(PIN9));
        esp32::delay_ms(10);
    }
}

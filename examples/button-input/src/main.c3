module button_input;

import esp32c3::hal::gpio;
import esp32c3;

fn void main() @export("start")
{
    gpio::mode(PIN8, OUTPUT);
    gpio::mode(PIN9, INPUT_PULLUP);

    while (true)
    {
        gpio::write(PIN8, !gpio::read(PIN9));
        esp32c3::delay_ms(10);
    }
}

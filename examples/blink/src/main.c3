module blink;

import esp32c3::hal::gpio;
import esp32c3;

fn void main() @export("start") 
{
    gpio::mode(PIN8, OUTPUT);

    while (true)
    {
        gpio::write(PIN8, true);
        esp32c3::delay_ms(250);
        gpio::write(PIN8, false);
        esp32c3::delay_ms(250);
    }
}

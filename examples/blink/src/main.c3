module blink;

import esp32::hal::gpio;
import esp32;

fn void main() @export("start") 
{
    gpio::mode(PIN8, OUTPUT);

    while (true)
    {
        gpio::write(PIN8, true);
        esp32::delay_ms(250);
        gpio::write(PIN8, false);
        esp32::delay_ms(250);
    }
}

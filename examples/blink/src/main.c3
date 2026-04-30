module blink;

import esp32c3;

fn void main() @export("start") 
{
    esp32c3::pin_out(PIN8);

    while (true)
    {
        esp32c3::pin_on(PIN8);
        esp32c3::delay_ms(250);
        esp32c3::pin_off(PIN8);
        esp32c3::delay_ms(250);
    }
}

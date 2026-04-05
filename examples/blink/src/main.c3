module blink;

import esp32c3;

fn void main() @export("main") @noreturn
{
    esp32c3::pin_out(esp32c3::PIN8);

    while (true)
    {
        esp32c3::pin_on(esp32c3::PIN8);
        esp32c3::delay_ms(250);
        esp32c3::pin_off(esp32c3::PIN8);
        esp32c3::delay_ms(250);
    }
}

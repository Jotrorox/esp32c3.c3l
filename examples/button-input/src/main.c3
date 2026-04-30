module button_input;

import esp32c3;

fn void main() @export("start")
{
    // Configure LED on PIN8 as output
    esp32c3::pin_out(PIN8);

    // Configure button on PIN9 as input with internal pull-up
    esp32c3::pin_in_pullup(PIN9);

    while (true)
    {
        // Read button state (active low because of pull-up)
        if (esp32c3::pin_read(PIN9))
        {
            // Button released (high due to pull-up)
            esp32c3::pin_off(PIN8);
        }
        else
        {
            // Button pressed (low when grounded)
            esp32c3::pin_on(PIN8);
        }

        esp32c3::delay_ms(10);
    }
}

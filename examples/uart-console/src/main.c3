module uart_console;

import esp32c3;

fn void main() @export("start") @noreturn
{
    esp32c3::printn("uart console example");
    esp32c3::printn("printing once per second");

    while (true)
    {
        esp32c3::print("hello world");
        esp32c3::delay_ms(1000);
    }
}

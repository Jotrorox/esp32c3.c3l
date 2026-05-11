module uart_console;

import esp32;

fn void main() @export("start") @noreturn
{
    esp32::printn("uart console example");
    esp32::printn("printing once per second");

    while (true)
    {
        esp32::printn("hello world");
        esp32::delay_ms(1000);
    }
}

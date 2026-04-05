module blink;

import esp32c3;

const uint GPIO_BASE = 0x6000_4000;
const uint GPIO_ENABLE_W1TS = GPIO_BASE + 0x024;

macro uint reg_read(uint addr)
{
    return *((uint*)addr);
}

fn void delay(uint cycles)
{
    uint i = 0;
    while (i < cycles)
    {
        reg_read(GPIO_ENABLE_W1TS);
        i += 1;
    }
}

fn void main() @export("main") @noreturn
{
    esp32c3::pin_out(esp32c3::PIN8);

    while (true)
    {
        esp32c3::pin_on(esp32c3::PIN8);
        delay(400_000);
        esp32c3::pin_off(esp32c3::PIN8);
        delay(400_000);
    }
}

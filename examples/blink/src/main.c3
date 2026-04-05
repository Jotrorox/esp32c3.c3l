module blink;

import espc3;

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
    espc3::pin_out(espc3::PIN8);

    while (true)
    {
        espc3::pin_on(espc3::PIN8);
        delay(400_000);
        espc3::pin_off(espc3::PIN8);
        delay(400_000);
    }
}

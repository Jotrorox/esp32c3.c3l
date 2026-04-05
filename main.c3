module blink;

const uint GPIO_BASE        = 0x6000_4000;
const uint GPIO_OUT_W1TS    = GPIO_BASE + 0x008;   // set bit HIGH
const uint GPIO_OUT_W1TC    = GPIO_BASE + 0x00C;   // set bit LOW
const uint GPIO_ENABLE_W1TS = GPIO_BASE + 0x024;   // enable as output

const uint GPIO_FUNC8_OUT_SEL = GPIO_BASE + 0x554 + 8 * 4;
const uint IO_MUX_GPIO8       = 0x6000_9000 + 0x004 + 8 * 4;
const uint IO_MUX_GPIO8_VAL   = (2u << 10) | (1u << 12);
const uint GPIO_FUNC8_OUT_SEL_VAL = 0x80u | (1u << 9);

const uint LED_BIT = 1u << 8;

macro void reg_write(uint $addr, uint $val) {
    *((uint*)$addr) = $val;
}

macro uint reg_read(uint $addr) {
    return *((uint*)$addr);
}

fn void delay(uint cycles) {
    uint i = 0;
    while (i < cycles) {
        reg_read(GPIO_ENABLE_W1TS);
        i += 1;
    }
}

fn void main() @export("main") @noreturn {
    reg_write(IO_MUX_GPIO8, IO_MUX_GPIO8_VAL);

    reg_write(GPIO_FUNC8_OUT_SEL, GPIO_FUNC8_OUT_SEL_VAL);

    reg_write(GPIO_ENABLE_W1TS, LED_BIT);

    while (true) {
        reg_write(GPIO_OUT_W1TS, LED_BIT);
        delay(4_000_000);
        reg_write(GPIO_OUT_W1TC, LED_BIT);
        delay(4_000_000);
    }
}

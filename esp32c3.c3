module esp32c3 @private;

const uint GPIO_BASE = 0x6000_4000;
const uint IO_MUX_BASE = 0x6000_9000;

const uint GPIO_OUT_W1TS = GPIO_BASE + 0x008;
const uint GPIO_OUT_W1TC = GPIO_BASE + 0x00C;
const uint GPIO_ENABLE_W1TS = GPIO_BASE + 0x024;

const uint GPIO_FUNC_OUT_SEL_BASE = GPIO_BASE + 0x554;
const uint GPIO_FUNC_OUT_SEL_STRIDE = 4;

const uint IO_MUX_GPIO_BASE = IO_MUX_BASE + 0x004;
const uint IO_MUX_GPIO_STRIDE = 4;

const uint IO_MUX_OUTPUT_VALUE = (2u << 10) | (1u << 12);
const uint GPIO_FUNC_OUTPUT_VALUE = 0x80u | (1u << 9);

macro void reg_write(uint addr, uint value)
{
	*((uint*)addr) = value;
}

<*
	@require pin <= 21 : "ESP32-C3 GPIO pins are 0 through 21"
*>
fn uint pin_mask(uint pin) @private
{
	return 1u << pin;
}

<*
	@require pin <= 21 : "ESP32-C3 GPIO pins are 0 through 21"
*>
fn uint pin_io_mux_reg(uint pin) @private
{
	return IO_MUX_GPIO_BASE + pin * IO_MUX_GPIO_STRIDE;
}

<*
	@require pin <= 21 : "ESP32-C3 GPIO pins are 0 through 21"
*>
fn uint pin_out_sel_reg(uint pin) @private
{
	return GPIO_FUNC_OUT_SEL_BASE + pin * GPIO_FUNC_OUT_SEL_STRIDE;
}

<*
	@require pin <= 21 : "ESP32-C3 GPIO pins are 0 through 21"
*>
fn void pin_out_impl(uint pin) @private
{
	reg_write(pin_io_mux_reg(pin), IO_MUX_OUTPUT_VALUE);
	reg_write(pin_out_sel_reg(pin), GPIO_FUNC_OUTPUT_VALUE);
	reg_write(GPIO_ENABLE_W1TS, pin_mask(pin));
}

<*
	@require pin <= 21 : "ESP32-C3 GPIO pins are 0 through 21"
*>
fn void pin_on_impl(uint pin) @private
{
	reg_write(GPIO_OUT_W1TS, pin_mask(pin));
}

<*
	@require pin <= 21 : "ESP32-C3 GPIO pins are 0 through 21"
*>
fn void pin_off_impl(uint pin) @private
{
	reg_write(GPIO_OUT_W1TC, pin_mask(pin));
}

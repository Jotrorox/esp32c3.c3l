module esp32c3::hal::gpio @private;

const uint GPIO_BASE = 0x6000_4000;
const uint IO_MUX_BASE = 0x6000_9000;
const uint TIMG0_BASE = 0x6001_F000;

const uint GPIO_OUT_W1TS = GPIO_BASE + 0x008;
const uint GPIO_OUT_W1TC = GPIO_BASE + 0x00C;
const uint GPIO_ENABLE_W1TS = GPIO_BASE + 0x024;
const uint GPIO_ENABLE_W1TC = GPIO_BASE + 0x028;
const uint GPIO_IN_REG = GPIO_BASE + 0x03C;

const uint GPIO_FUNC_OUT_SEL_BASE = GPIO_BASE + 0x554;
const uint GPIO_FUNC_OUT_SEL_STRIDE = 4;

const uint IO_MUX_GPIO_BASE = IO_MUX_BASE + 0x004;
const uint IO_MUX_GPIO_STRIDE = 4;

const uint IO_MUX_INPUT_VALUE = (1u << 12) | (1u << 9);
const uint IO_MUX_INPUT_PULLUP_VALUE = (1u << 12) | (1u << 9) | (1u << 8);
const uint IO_MUX_INPUT_PULLDOWN_VALUE = (1u << 12) | (1u << 9) | (1u << 7);

const uint IO_MUX_OUTPUT_VALUE = (2u << 10) | (1u << 12);
const uint GPIO_FUNC_OUTPUT_VALUE = 0x80u | (1u << 9);

const uint TIMG_WDTFEED_OFFSET = 0x0060;

macro void reg_write(uint addr, uint value)
{
	@volatile_store(*(uint*)addr, value);
}

macro uint reg_read(uint addr)
{
	return @volatile_load(*(uint*)addr);
}

fn void feed_mwdt() @private
{
	reg_write(TIMG0_BASE + TIMG_WDTFEED_OFFSET, 1);
}

fn uint pin_mask(Pin pin) @private
{
	return 1u << (uint)pin;
}

fn uint pin_io_mux_reg(Pin pin) @private
{
	return IO_MUX_GPIO_BASE + (uint)pin * IO_MUX_GPIO_STRIDE;
}

fn uint pin_out_sel_reg(Pin pin) @private
{
	return GPIO_FUNC_OUT_SEL_BASE + (uint)pin * GPIO_FUNC_OUT_SEL_STRIDE;
}

fn void mode_impl(Pin pin, PinMode mode) @private
{
	feed_mwdt();
	switch (mode)
	{
		case OUTPUT:
			reg_write(pin_io_mux_reg(pin), IO_MUX_OUTPUT_VALUE);
			reg_write(pin_out_sel_reg(pin), GPIO_FUNC_OUTPUT_VALUE);
			reg_write(GPIO_ENABLE_W1TS, pin_mask(pin));
		case INPUT:
			reg_write(pin_io_mux_reg(pin), IO_MUX_INPUT_VALUE);
			reg_write(GPIO_ENABLE_W1TC, pin_mask(pin));
		case INPUT_PULLUP:
			reg_write(pin_io_mux_reg(pin), IO_MUX_INPUT_PULLUP_VALUE);
			reg_write(GPIO_ENABLE_W1TC, pin_mask(pin));
		case INPUT_PULLDOWN:
			reg_write(pin_io_mux_reg(pin), IO_MUX_INPUT_PULLDOWN_VALUE);
			reg_write(GPIO_ENABLE_W1TC, pin_mask(pin));
	}
}

fn void write_impl(Pin pin, bool value) @private
{
	feed_mwdt();
	if (value)
	{
		reg_write(GPIO_OUT_W1TS, pin_mask(pin));
	}
	else
	{
		reg_write(GPIO_OUT_W1TC, pin_mask(pin));
	}
}

fn bool read_impl(Pin pin) @private
{
	feed_mwdt();
	return (reg_read(GPIO_IN_REG) & pin_mask(pin)) != 0;
}

module esp32c3 @private;

const uint GPIO_BASE = 0x6000_4000;
const uint IO_MUX_BASE = 0x6000_9000;
const uint SYSTIMER_BASE = 0x6002_3000;
const uint TIMG0_BASE = 0x6001_F000;
const uint TIMG1_BASE = 0x6002_0000;
const uint RTC_CNTL_BASE = 0x6000_8000;
const uint SYSTEM_BASE = 0x600C_0000;

const uint GPIO_OUT_W1TS = GPIO_BASE + 0x008;
const uint GPIO_OUT_W1TC = GPIO_BASE + 0x00C;
const uint GPIO_ENABLE_W1TS = GPIO_BASE + 0x024;

const uint GPIO_FUNC_OUT_SEL_BASE = GPIO_BASE + 0x554;
const uint GPIO_FUNC_OUT_SEL_STRIDE = 4;

const uint IO_MUX_GPIO_BASE = IO_MUX_BASE + 0x004;
const uint IO_MUX_GPIO_STRIDE = 4;

const uint SYSTIMER_CONF = SYSTIMER_BASE + 0x0000;
const uint SYSTIMER_UNIT0_OP = SYSTIMER_BASE + 0x0004;
const uint SYSTIMER_UNIT0_VALUE_HI = SYSTIMER_BASE + 0x0040;
const uint SYSTIMER_UNIT0_VALUE_LO = SYSTIMER_BASE + 0x0044;
const uint TIMG_WDTCONFIG0_OFFSET = 0x0048;
const uint TIMG_WDTFEED_OFFSET = 0x0060;
const uint TIMG_WDTWPROTECT_OFFSET = 0x0064;
const uint RTC_CNTL_WDTCONFIG0 = RTC_CNTL_BASE + 0x0090;
const uint RTC_CNTL_WDTWPROTECT = RTC_CNTL_BASE + 0x00A8;
const uint RTC_CNTL_SWD_CONF = RTC_CNTL_BASE + 0x00AC;
const uint RTC_CNTL_SWD_WPROTECT = RTC_CNTL_BASE + 0x00B0;

const uint SYSTEM_PERIP_CLK_EN0 = SYSTEM_BASE + 0x0010;
const uint SYSTEM_PERIP_RST_EN0 = SYSTEM_BASE + 0x0018;

const uint IO_MUX_OUTPUT_VALUE = (2u << 10) | (1u << 12);
const uint GPIO_FUNC_OUTPUT_VALUE = 0x80u | (1u << 9);

const uint SYSTIMER_CLK_EN_BIT = 31;
const uint SYSTIMER_TIMER_UNIT0_WORK_EN_BIT = 30;
const uint SYSTIMER_TIMER_UNIT0_CORE0_STALL_EN_BIT = 28;
const uint SYSTIMER_TIMER_UNIT0_UPDATE_BIT = 30;
const uint SYSTIMER_TIMER_UNIT0_VALUE_VALID_BIT = 29;
const uint SYSTIMER_UNIT0_HI_MASK = 0x000F_FFFF;
const uint SYSTEM_SYSTIMER_CLK_EN_BIT = 30;
const uint SYSTEM_SYSTIMER_RST_BIT = 30;
const uint TIMG_WDT_CONF_UPDATE_BIT = 13;
const uint TIMG_WDT_WKEY_VALUE = 0x50D8_3AA1;
const uint RTC_CNTL_SWD_AUTO_FEED_EN_BIT = 31;
const uint RTC_CNTL_SWD_WKEY_VALUE = 0x8F1D_312A;
const usz ROM_UART_TX_ONE_CHAR_ADDR = 0x4000_0068;

bool delay_timer_ready @local = false;
bool boot_ready @local = false;

alias RomTxOneChar = fn int(char);

const RomTxOneChar ROM_UART_TX_ONE_CHAR = (RomTxOneChar)ROM_UART_TX_ONE_CHAR_ADDR;

macro void reg_write(uint addr, uint value)
{
	*((uint*)addr) = value;
}

macro uint reg_read(uint addr)
{
	return *((uint*)addr);
}

fn void disable_mwdt(uint timer_group_base) @private
{
	reg_write(timer_group_base + TIMG_WDTWPROTECT_OFFSET, TIMG_WDT_WKEY_VALUE);
	reg_write(timer_group_base + TIMG_WDTFEED_OFFSET, 1);
	reg_write(timer_group_base + TIMG_WDTCONFIG0_OFFSET, 0);
	reg_write(timer_group_base + TIMG_WDTCONFIG0_OFFSET, 1u << TIMG_WDT_CONF_UPDATE_BIT);
	reg_write(timer_group_base + TIMG_WDTWPROTECT_OFFSET, 0);
}

fn void feed_mwdt(uint timer_group_base) @private
{
	reg_write(timer_group_base + TIMG_WDTFEED_OFFSET, 1);
}

fn void boot_init() @private
{
	if (boot_ready)
	{
		return;
	}

	disable_mwdt(TIMG0_BASE);
	disable_mwdt(TIMG1_BASE);
	reg_write(RTC_CNTL_WDTWPROTECT, TIMG_WDT_WKEY_VALUE);
	reg_write(RTC_CNTL_WDTCONFIG0, 0);
	reg_write(RTC_CNTL_WDTWPROTECT, 0);
	reg_write(RTC_CNTL_SWD_WPROTECT, RTC_CNTL_SWD_WKEY_VALUE);
	reg_write(
		RTC_CNTL_SWD_CONF,
		reg_read(RTC_CNTL_SWD_CONF) | (1u << RTC_CNTL_SWD_AUTO_FEED_EN_BIT)
	);
	reg_write(RTC_CNTL_SWD_WPROTECT, 0);
	feed_mwdt(TIMG0_BASE);
	boot_ready = true;
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
	boot_init();
	feed_mwdt(TIMG0_BASE);
	reg_write(pin_io_mux_reg(pin), IO_MUX_OUTPUT_VALUE);
	reg_write(pin_out_sel_reg(pin), GPIO_FUNC_OUTPUT_VALUE);
	reg_write(GPIO_ENABLE_W1TS, pin_mask(pin));
}

<*
	@require pin <= 21 : "ESP32-C3 GPIO pins are 0 through 21"
*>
fn void pin_on_impl(uint pin) @private
{
	feed_mwdt(TIMG0_BASE);
	reg_write(GPIO_OUT_W1TS, pin_mask(pin));
}

<*
	@require pin <= 21 : "ESP32-C3 GPIO pins are 0 through 21"
*>
fn void pin_off_impl(uint pin) @private
{
	feed_mwdt(TIMG0_BASE);
	reg_write(GPIO_OUT_W1TC, pin_mask(pin));
}

fn void uart_write_byte_impl(char byte) @private
{
	boot_init();
	feed_mwdt(TIMG0_BASE);
	ROM_UART_TX_ONE_CHAR(byte);
}

fn void uart_write_impl(char* text) @private
{
	while (*text)
	{
		uart_write_byte_impl(*text);
		text++;
	}
}

fn void uart_write_line_impl(char* text) @private
{
	uart_write_impl(text);
	uart_write_byte_impl('\r');
	uart_write_byte_impl('\n');
}

fn ulong systimer_unit0_read_count() @private
{
	reg_write(SYSTIMER_UNIT0_OP, 1u << SYSTIMER_TIMER_UNIT0_VALUE_VALID_BIT);
	reg_write(SYSTIMER_UNIT0_OP, 1u << SYSTIMER_TIMER_UNIT0_UPDATE_BIT);
	while ((reg_read(SYSTIMER_UNIT0_OP) & (1u << SYSTIMER_TIMER_UNIT0_VALUE_VALID_BIT)) == 0)
	{
	}

	uint lo = reg_read(SYSTIMER_UNIT0_VALUE_LO);
	uint hi = reg_read(SYSTIMER_UNIT0_VALUE_HI) & SYSTIMER_UNIT0_HI_MASK;
	return ((ulong)hi << 32) | lo;
}

fn void delay_timer_init() @private
{
	boot_init();

	reg_write(
		SYSTEM_PERIP_CLK_EN0,
		reg_read(SYSTEM_PERIP_CLK_EN0) | (1u << SYSTEM_SYSTIMER_CLK_EN_BIT)
	);
	reg_write(
		SYSTEM_PERIP_RST_EN0,
		reg_read(SYSTEM_PERIP_RST_EN0) & ~(1u << SYSTEM_SYSTIMER_RST_BIT)
	);

	uint cfg = reg_read(SYSTIMER_CONF);
	cfg |= 1u << SYSTIMER_CLK_EN_BIT;
	cfg |= 1u << SYSTIMER_TIMER_UNIT0_WORK_EN_BIT;
	cfg &= ~(1u << SYSTIMER_TIMER_UNIT0_CORE0_STALL_EN_BIT);
	reg_write(SYSTIMER_CONF, cfg);

	delay_timer_ready = true;
}

fn void delay_timer_ensure_init() @private
{
	if (!delay_timer_ready)
	{
		delay_timer_init();
	}
}

fn void delay_us_impl(uint us) @private
{
	delay_timer_ensure_init();
	feed_mwdt(TIMG0_BASE);

	ulong start = systimer_unit0_read_count();
	ulong target = (ulong)us << 4;
	while (systimer_unit0_read_count() - start < target)
	{
		feed_mwdt(TIMG0_BASE);
	}
}

fn void delay_ms_impl(uint ms) @private
{
	delay_timer_ensure_init();
	feed_mwdt(TIMG0_BASE);

	ulong start = systimer_unit0_read_count();
	ulong ms64 = (ulong)ms;
	ulong target = (ms64 << 14) - (ms64 << 8) - (ms64 << 7);
	while (systimer_unit0_read_count() - start < target)
	{
		feed_mwdt(TIMG0_BASE);
	}
}

module esp32::hal::uart @private;

const uint TIMG0_BASE = 0x6001_F000;
const uint TIMG_WDTFEED_OFFSET = 0x0060;

const usz ROM_UART_TX_ONE_CHAR_ADDR = 0x4000_0068;
const usz ROM_UART_TX_FLUSH_ADDR = 0x4000_0080;

alias RomTxOneChar = fn int(char);
alias RomTxFlush = fn void();

const RomTxOneChar ROM_UART_TX_ONE_CHAR = (RomTxOneChar)ROM_UART_TX_ONE_CHAR_ADDR;
const RomTxFlush ROM_UART_TX_FLUSH = (RomTxFlush)ROM_UART_TX_FLUSH_ADDR;

macro void reg_write(uint addr, uint value)
{
	@volatile_store(*(uint*)addr, value);
}

fn void feed_mwdt() @private
{
	reg_write(TIMG0_BASE + TIMG_WDTFEED_OFFSET, 1);
}

fn void uart_write_byte_impl(char byte) @private
{
	feed_mwdt();
	ROM_UART_TX_ONE_CHAR(byte);
}

fn void uart_tx_flush_impl() @private
{
	ROM_UART_TX_FLUSH();
}

fn void uart_print_impl(char* text) @private
{
	while (*text)
	{
		uart_write_byte_impl(*text);
		text++;
	}
	ROM_UART_TX_FLUSH();
}

fn void print_uint_impl(uint v) @private
{
	char[16] buf;
	int i = 15;
	buf[i] = 0;
	if (v == 0)
	{
		uart_write_byte_impl('0');
		return;
	}
	while (v > 0)
	{
		buf[--i] = '0' + (char)(v % 10);
		v /= 10;
	}
	char* p = &buf[i];
	while (*p) uart_write_byte_impl(*p++);
}

fn void print_int_impl(int v) @private
{
	if (v < 0)
	{
		uart_write_byte_impl('-');
		print_uint_impl((uint)(-v));
	}
	else
	{
		print_uint_impl((uint)v);
	}
}

fn void print_hex_impl(uint v, bool uppercase) @private
{
	char[16] buf;
	int i = 15;
	buf[i] = 0;
	if (v == 0)
	{
		uart_write_byte_impl('0');
		return;
	}
	char a = uppercase ? 'A' : 'a';
	while (v > 0)
	{
		uint digit = v % 16;
		buf[--i] = (char)(digit < 10 ? '0' + digit : a + (digit - 10));
		v /= 16;
	}
	char* p = &buf[i];
	while (*p) uart_write_byte_impl(*p++);
}

fn void print_ptr_impl(void* p) @private
{
	uart_write_byte_impl('0');
	uart_write_byte_impl('x');
	print_hex_impl((uint)(usz)p, false);
}

fn void print_bool_impl(bool v) @private
{
	if (v)
	{
		uart_print_impl("true");
	}
	else
	{
		uart_print_impl("false");
	}
}

fn int any_to_int_impl(any arg) @private
{
	switch (arg.type)
	{
		case ichar: return (int)*(ichar*)arg.ptr;
		case short: return (int)*(short*)arg.ptr;
		case int: return *(int*)arg.ptr;
		case long: return (int)*(long*)arg.ptr;
		case char: return (int)*(char*)arg.ptr;
		case ushort: return (int)*(ushort*)arg.ptr;
		case uint: return (int)*(uint*)arg.ptr;
		case ulong: return (int)*(ulong*)arg.ptr;
		default: return 0;
	}
}

fn uint any_to_uint_impl(any arg) @private
{
	switch (arg.type)
	{
		case ichar: return (uint)*(ichar*)arg.ptr;
		case short: return (uint)*(short*)arg.ptr;
		case int: return (uint)*(int*)arg.ptr;
		case long: return (uint)*(long*)arg.ptr;
		case char: return (uint)*(char*)arg.ptr;
		case ushort: return (uint)*(ushort*)arg.ptr;
		case uint: return *(uint*)arg.ptr;
		case ulong: return (uint)*(ulong*)arg.ptr;
		default: return 0;
	}
}

fn void printf_impl(char* fmt, any[] args) @private
{
	int arg_idx = 0;
	while (*fmt)
	{
		if (*fmt == '%')
		{
			fmt++;
			if (*fmt == '%')
			{
				uart_write_byte_impl('%');
				fmt++;
				continue;
			}

			bool is_long = false;
			if (*fmt == 'l')
			{
				is_long = true;
				fmt++;
			}

			if (arg_idx >= (int)args.len)
			{
				uart_write_byte_impl('%');
				uart_write_byte_impl(*fmt);
				fmt++;
				continue;
			}

			any arg = args[arg_idx++];
			switch (*fmt)
			{
				case 'd':
				case 'i':
					if (is_long) { print_int_impl((int)*(long*)arg.ptr); }
					else { print_int_impl(any_to_int_impl(arg)); }
					break;
				case 'u':
					if (is_long) { print_uint_impl((uint)*(ulong*)arg.ptr); }
					else { print_uint_impl(any_to_uint_impl(arg)); }
					break;
				case 'x':
					print_hex_impl(any_to_uint_impl(arg), false);
					break;
				case 'X':
					print_hex_impl(any_to_uint_impl(arg), true);
					break;
				case 'c':
					uart_write_byte_impl((char)any_to_int_impl(arg));
					break;
				case 's':
					uart_print_impl((char*)arg.ptr);
					break;
				case 'p':
					print_ptr_impl(*(void**)arg.ptr);
					break;
				default:
					uart_write_byte_impl('%');
					uart_write_byte_impl(*fmt);
					break;
			}
			fmt++;
		}
		else
		{
			uart_write_byte_impl(*fmt++);
		}
	}
}

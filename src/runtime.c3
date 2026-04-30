module runtime @private;

fn int __mulsi3(int a, int b) @export("__mulsi3")
{
	uint ua = (uint)a;
	uint ub = (uint)b;
	uint res = 0;
	while (ub != 0)
	{
		if (ub & 1) res += ua;
		ua <<= 1;
		ub >>= 1;
	}
	return (int)res;
}

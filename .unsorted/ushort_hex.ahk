FormatHexNumber(_value, _digitNb)
{
	local hex, intFormat

	; Save original integer format
	intFormat := A_FormatInteger
	; For converting bytes to hex
	SetFormat Integer, Hex

	hex := _value + (1 << 4 * _digitNb)
	StringRight hex, hex, _digitNb
	; I prefer my hex numbers to be in upper case
	StringUpper hex, hex

	; Restore original integer format
	SetFormat Integer, %intFormat%

	Return hex
}

ushort_hex(ptr, len){
	hex =
	loop, % len
	{
		i := (A_Index - 1) * 2
		p := ptr + i
		hex .= FormatHexNumber(*p, 2)
	}
	return hex
}
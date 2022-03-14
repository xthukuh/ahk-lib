xsplit_delim(str, size := 0, delim := " ", rtl := 1){
	len := StrLen(str)
	if (!len || !size)
		return str
	buf =
	loop, % Ceil(len/size)
	{
		if rtl
		{
			i := len - ((A_Index - 1) * size) - 1
			val := i < 0 ? "00" : (i == 0 ? "0" SubStr(hex, 1, 1) : SubStr(hex, i, 2))
		}
		arr.InsertAt(1, val)
		;str .= i "-" val "`n"
	}
	if len
	{
		buf =
		loop, % Ceil(StrLen(str)/len)
		{
			i := ((A_Index - 1) * len) + 1
			tmp := SubStr(str, i, len)
			buf .= (buf != "" ? delim : "") tmp
		}
		str := buf
	}
	return str
}
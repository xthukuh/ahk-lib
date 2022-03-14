/*
	String Split Helper - By Martin Thuku
	Breaks apart "str" into chunks of specified "size"
	Set "rtl = 1" to split from right to left
	Set "pad" to pad chunks to fit "size"
	- Note pad is prepended if "rtl = 1" otherwise appended
	Returns if "to_list = 1" array of chunks otherwise "glue" delimited string

	Example:
	xstr_split(str := "001111", size := 4, to_list := 0, rtl := 1, glue := " ", pad := "0") ;0000 1111
*/
xstr_split(str, size, to_list := 0, rtl := 0, glue := " ", pad := ""){
	if size is not integer
		Throw, "Invalid xstr_split size!"
	if ((size := Abs(size)) < 1 || !(len := StrLen(str)))
		return
	buf := to_list ? [] : ""
	loop, % Ceil(len/size)
	{
		if rtl
		{
			s := size
			p := ((A_Index - 1) * size) + size
			if ((i := len - p + 1) < 1)
			{
				s := i - 1 + size
				i := 1
			}
			v := SubStr(str, i, s)
		}
		else {
			p := (A_Index - 1) * size
			i := p + 1
			v := SubStr(str, i, s := size)
		}
		if (StrLen(v) < size && pad != "")
		{
			while (StrLen(v) < size)
				v := rtl ? pad v : v pad
		}
		if to_list
		{
			if rtl
				buf.InsertAt(1, v)
			else buf.Insert(v)
		}
		else {
			if rtl
				buf := v (buf != "" ? glue : "") buf
			else buf .= (buf != "" ? glue : "") v
		}
	}
	return buf
}

;split bin
xstr_split_b(v, _size := 8, _to_list := 0){
	return xstr_split(v, _size, _to_list, _rtl := 1, _glue := " ", _pad := "0")
}

;split hex
xstr_split_h(v, _size := 2, _to_list := 0){
	return xstr_split(v, _size, _to_list, _rtl := 1, _glue := " ", _pad := "0")
}
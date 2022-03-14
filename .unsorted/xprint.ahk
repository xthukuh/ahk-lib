xprint(value, padding := "    ", _depth := 0){
	pad := xrepeat(padding, _depth)
	if isObject(value)
	{
		str := pad "{"
		for key, val in value
		{
			key := qstr(key)
			val := qstr(ltrim(IsObject(val) ? xprint(val, padding, _depth + 1) : val))
			str .= "`n" pad padding key ": " val
		}
		str .= "`n" pad "}"
		return str
	}
	return pad qstr(value)
}

__xprint_valx(value, _quote := """"){
	return _quote xstr(value) _quote
}
__xprint_val(value, _quote := """"){
	if value is not number
		value := _quote value _quote
	else if (value == 0)
		value := Format("{:d}", 0)
	return value
}

#Include <xstr>
#Include <xrepeat>
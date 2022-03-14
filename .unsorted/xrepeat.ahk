xrepeat(value, _count := 1, _join := ""){
	buffer := "", count := floor(_count * 1)
	if (count > 0)
	{
		buffer := __xrepeat_val(value)
		loop, % (count - 1)
			buffer .= _join __xrepeat_val(value, A_Index + 1)
	}
	return buffer
}

__xrepeat_val(value, index := 1){
	return RegExReplace(value, "i)\{i\}", index)
}
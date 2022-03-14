xbin(value, _bits := 8, _split := 8){
	x := value
	r := ""
	while x
	{
		r := 1 & x r
		x >>= 1
	}
	if (m := Mod(len := StrLen(r), _bits))
	{
		max := len > _bits ? (m ? len + (_bits - m) : len) : _bits
		loop, % (max - len)
			r := "0" r
	}
	if !(len := StrLen(r))
	{
		r := ""
		loop, % _bits
			r .= "0"
	}
	return _split > 0 ? xstr_split_b(r, _split) : r
}

;requires xstr_split
#Include *i %A_LineFile%\..\xstr_split.ahk
;string binary
sbin(str, _split := 0){
	loop, parse, str
	{
		Transform, dec, Asc, %A_LoopField%
		allbin=
		loop, 8
		{
			Transform, bin, BitAND,dec, 1
			Transform, dec, BitShiftRight,dec,1
			allbin= %bin%%allbin%
		}
		binary=%binary%%allbin%
	}
	if (_split := Abs(_split * 1)) >= 1
		binary := xstr_split_b(binary, _split)
	return binary
}

;requires
#Include *i %A_LineFile%\..\xstr_split.ahk
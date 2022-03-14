/*
	Extract string from pointer
	mode == 1 - including nulls (0x00)
*/

xptr_str(ptr, len, mode := 0, ByRef hex := "", rtl := 0){
	if ptr is not integer
		throw "xptr_str expects ptr to be an integer"
	hex := "", nul := ""
	VarSetCapacity(str, len, 0)
	loop, % len
	{
		if (n := *(ptr + A_Index - 1))
		{
			char := Chr(n)
			h := Format("{:02x}", n)
			StringUpper, h, h
			hex := rtl ? h hex : hex h
			str := rtl ? char str : str char
		}
		else {
			h := "00"
			if (mode == 1){
				if (!StrLen(nul))
					nul := xnull()
				char := nul
			}
			else char := Chr(n)
			str := rtl ? char str : str char
			hex := rtl ? h hex : hex h
		}
	}
	return str
}

;requires
#Include *i %A_LineFile%\..\xnull.ahk
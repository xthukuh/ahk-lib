;url encode
xurl_encode(str, enc := "UTF-8"){
	len := StrPut(str, enc) * (enc = "UTF-16" || enc = "CP1200" ? 2 : 1)
	VarSetCapacity(var, len, 0)
	StrPut(str, &var, enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	loop
	{
		if !(code := NumGet(var, A_Index - 1, "UChar"))
			break
		if (code >= 0x30 && code <= 0x39 || code >= 0x41 && code <= 0x5A || code >= 0x61 && code <= 0x7A)
			res .= Chr(code)
		else res .= "%" . SubStr(code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
	return res
}
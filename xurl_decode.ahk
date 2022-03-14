;url decode
xurl_decode(str, enc := "UTF-8"){
	pos := 1
	loop
	{
		pos := RegExMatch(str, "i)(?:%[\da-f]{2})+", code, pos++)
		If (pos = 0)
			Break
		VarSetCapacity(var, StrLen(code) // 3, 0)
		StringTrimLeft, code, code, 1
		loop, parse, code, `%
			NumPut("0x" . A_LoopField, var, A_Index - 1, "UChar")
		StringReplace, str, str, `%%code%, % StrGet(&var, enc), All
	}
	return str
}
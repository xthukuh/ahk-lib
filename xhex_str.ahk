/*
	https://www.autohotkey.com/boards/viewtopic.php?t=3925
	hex to string (mode = 1: include null (0x00))

	xhex_str("0x41 0x75 0x74 0x6f 0x48 0x6f 0x74 0x6b 0x65 0x79")	; AutoHotkey
	xhex_str("4175746f486f746b6579")								; AutoHotkey
*/
xhex_str(_hex, mode := 0){
	static u := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
	if (!(len := Strlen(hex := __hex_str_value(_hex))))
		return
	
	;fix hex length
	if Mod(len, 2)
	{
		hex := "0" hex
		len += 1
	}
	
	;string buffer
	str := ""
	len := len / 2
	nul := mode == 1 ? xnull() : ""
	loop, % len
	{
		h := "0x" SubStr(hex, (A_Index * 2) - 1, 2)
		char := Chr(DllCall("msvcrt.dll\" u, "Str", h, "Uint", 0, "UInt", 16, "CDECL Int64"))
		str .= mode == 1 && !(h * 1) ? nul : char
	}

	;result
	return str
}

;hex string value - concat even hex
__hex_str_value(val){
	if StrLen(val := Trim(val, " `r`n`t"))
	{
		val := RegExReplace(val, "0x", "")
		val := RegExReplace(val, "\s", "")
		val := Format("{:02}", val)
	}
	return val
}

;requires
#Include *i %A_LineFile%\..\xnull.ahk
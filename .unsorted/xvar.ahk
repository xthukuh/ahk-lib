xvar(address, program := ""){
	static _type_size := {UChar: 1, Char: 1, UShort: 2, Short: 2, UInt: 4, Int: 4, UFloat: 4, Float: 4, Int64: 8, Double: 8} 
	result =
	if !(pid := xpid(program))
		return xerror("Unable to get xvar PID")
	if !hProcess := DllCall("OpenProcess", "UInt", 24, "Char", 0, "UInt", pid)
		return xerror("Unable to get xvar process handle for pid " pid)
	result =
	VarSetCapacity(mvalue, 4, 0)
	;if DllCall("ReadProcessMemory", "UInt",  hProcess, "Ptr", address, type "*", result, "UInt", _type_size[type], "Ptr", 0)
	DllCall("ReadProcessMemory", "UInt",  hProcess, "Ptr", address, "Ptr", &mvalue, "UInt", 4)
	loop, 4
	{
		i := A_Index - 1
		result += *(&mvalue + i) << 8 * i
	}
	DllCall("CloseHandle", "UInt", hProcess)
	return result
}

_xvar(address, type := "UInt", program := ""){
	static _type_size := {UChar: 1, Char: 1, UShort: 2, Short: 2, UInt: 4, Int: 4, UFloat: 4, Float: 4, Int64: 8, Double: 8} 
	result =
	if !(pid := xpid(program))
		return xerror("Unable to get xvar PID")
	if !hProcess := DllCall("OpenProcess", "UInt", 24, "Int", False, "UInt", pid)
		return xerror("Unable to get xvar process handle for pid " pid)
	result =
	if DllCall("ReadProcessMemory", "UInt",  hProcess, "Ptr", address, type "*", result, "UInt", _type_size[type], "Ptr", 0)
	DllCall("CloseHandle", "UInt", hProcess)
	return result
}

#Include <xpid>
#Include <xerror>

/*
ClipboardData(){
	VarCap := VarSetCapacity(Source, 0)
	Source := ClipboardAll
	VarCap := VarSetCapacity(Source)
	Content := ""
	Loop, % VarCap
		Content .= Chr(NumGet(Source, A_Index-1, "UChar"))
	VarCap := VarSetCapacity(Content)
	return Content
}
*/
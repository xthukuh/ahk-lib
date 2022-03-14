;dump var string
xdump(ByRef var, len := 0, mode := 0, rtl := 0){
	len := len >= 1 ? len : StrPut(var, "UTF-8") - 1
	;s := "dump(" len ")`n"
	;s .= """" var """`n"
	;s .= "`n"
	s := ""
	s .= xdump_ptr(&var, len, mode, rtl)
	return s
}

;dump pointer string
xdump_ptr(ptr, len, mode := 0, rtl := 0){
	v := xptr_str(ptr, len, mode, h, rtl)
	;s := "ptr: " ptr " (" len ")`n"
	s .= h "`n"
	s .= sbin(v, 8) "`n"
	;s .= "`n" xdump_hex(h)
	return s
}

;dump hex
xdump_hex(h){
	b := xhex_bin(h, 8)
	s := "hex: " h "`n"
	s .= b "`n"
	return s
}

;requires
#Include *i %A_LineFile%\..\xptr_str.ahk
#Include *i %A_LineFile%\..\xhex_bin.ahk
#Include *i %A_LineFile%\..\sbin.ahk
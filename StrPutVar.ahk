;StrPutVar
StrPutVar(str, ByRef var, enc := ""){
	len := StrPut(str, enc) * (enc = "UTF-16" || enc = "CP1200" ? 2 : 1)
	VarSetCapacity(var, len, 0)
	return StrPut(str, &var, enc)
}
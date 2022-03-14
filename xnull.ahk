xnull(){
	static chr := ""
	if !StrLen(chr)
	{
		VarSetCapacity(val, 3, 0)
		NumPut(0xff00ff, val)
		chr := DllCall("MulDiv", int, &val + 1, int, 1, int, 1, str)
	}
	return chr
}
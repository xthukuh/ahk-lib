xcr(str, pass := "alohomora", enc := true){
	local n := 1, b := "", l := enc ? "" : "."
	loop, parse, str, %l%
	{
		p := asc(substr(pass, n, 1)), n := n > strlen(pass) ? 1 : (n + 1)
		t := enc ? (asc(A_LoopField) + p + 20) : chr(A_LoopField - p - 20)
		b .= b = "" ? t : (enc ? "." t : t)
	}
	return b
}
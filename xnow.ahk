xnow(timestamp := "", format := "yyyy-MM-dd HH:mm:ss"){
	if timestamp =
		timestamp := A_Now
	FormatTime, out, %timestamp%, %format%
	return out
}
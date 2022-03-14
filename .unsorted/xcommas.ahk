xcommas(num, places := 2){
	if ((num := xnum(num, "x")) == "x")
		return
	if num is float
		num := Round(num, places)
	return RegExReplace(num, "(\d)(?=(?:\d{3})+(?:\.|$))", "$1,")
}

#Include <xnum>
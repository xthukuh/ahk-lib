dsv(value, delimiter := ",", enclosure := """", escape := "\", _trim := false, _row := 1){
	if isObject(rows := xdsv(value, delimiter, enclosure, escape, _trim))
		return (_row := abs(floor(_row * 1))) && rows.HasKey(_row) ? rows[_row] : rows
	return []
}
xdsv(value, delimiter := ",", enclosure := """", escape := "\", _trim := false){
	global __xdsv__0000, __xdsv__0001
	if !(str := xtrim(value))
		return
	d := (d := xtrim(delimiter)) ? d : ","
	c := (c := xtrim(enclosure)) ? c : """"
	e := (e := xtrim(escape)) ? e : "\"
	str := StrReplace(str, "`r")
	str := StrReplace(str, "+", "!!P!!")
	str := StrReplace(str, e c, "!!C!!")
	str := StrReplace(str, c c, e c)
	str := StrReplace(str, e c, "!!C!!")
	xc := xreg(c)
	pattern := StrReplace("c([^c]+)c", "c", xc)
	__xdsv__0000 := str
	RegExReplace(str, pattern "(?C__xdsv__0000)")
	str := __xdsv__0000, __xdsv__0000 := ""
	pattern := StrReplace("c((?!c).*?(?=c))c", "c", xc)
	__xdsv__0001 := str
	RegExReplace(str, "O)" pattern "(?C__xdsv__0001)")
	str := __xdsv__0001, __xdsv__0001 := ""
	rows := []
	loop, parse, str, `n
	{
		if !(line := _trim ? xtrim(A_LoopField) : A_LoopField)
			continue
		cols := []
		loop, parse, line, %d%
		{
			if (col := _trim ? xtrim(A_LoopField) : A_LoopField)
			{
				col := urldecode(col)
				col := StrReplace(col, "!!N!!", "`r`n")
				col := StrReplace(col, "!!P!!", "+")
				col := StrReplace(col, "!!C!!", c)
			}
			cols.Insert(col)
		}
		if cols.Count()
			rows.Insert(cols)
	}
	return rows
}
__xdsv__0000(Match){
	global __xdsv__0000
	__xdsv__0000 := StrReplace(__xdsv__0000, Match, StrReplace(Match, "`n", "!!N!!"))
}
__xdsv__0001(Match){
	global __xdsv__0001
	__xdsv__0001 := StrReplace(__xdsv__0001, Match[0], urlencode(Match[1]))
}

#Include <xreg>
#Include <xtrim>
#Include <urlencode>
#Include <urldecode>
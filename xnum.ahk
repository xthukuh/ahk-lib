;number helpers - xnum
xnum(num, _default := 0){
	if ((num := StrReplace(num := Trim(num, " `t`r`n"), " ")) != "")
	{
		if num is number
			num := Format("{:f}", num)
		if RegExMatch(num, "O)^(-|\+|)(\d{1,3}(,?\d{3})*)(\.(\d*))?$", matches)
			return ((v := matches[1]) == "-" ? v : "") (StrReplace(matches[2], ",") * 1) ((v := rtrim(matches[5], "0")) ? "." v : "")
	}
	return _default
}

;abs num
anum(value, _default := 0){
	if ((num := xnum(value, "x")) == "x")
		return _default
	return num >= 0 ? num : xnum(Abs(num))
}

;int
xint(value, _default := 0){
	if ((num := xnum(value, "x")) == "x")
		return _default
	return Format("{:i}", num)
}

;abs int
aint(value, _default := 0){
	if ((num := xint(value, "x")) == "x")
		return _default
	return Abs(num)
}

;is num
xis_num(value, _parse := 0){
	num := _parse ? xnum(value, "x") : value
	if num is number
		return {value: num}
}

;is int
xis_int(value, _parse := 0){
	num := _parse ? xnum(value, "x") : value
	if num is integer
		return {value: num}
}

;is float
xis_float(value, _parse := 0){
	num := _parse ? xnum(value, "x") : value
	if num is float
		return {value: num}
}
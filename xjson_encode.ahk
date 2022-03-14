xjson_encode(obj){
	if IsObject(obj)
	{
		isarray := 0
		for key in obj
		{
			if (key != ++isarray)
			{
				isarray := 0
				break
			}
		}
		for key, val in obj
			str .= (A_Index = 1 ? "" : ",") (isarray ? "" : xjson_encode(key) ":") xjson_encode(val)
		return isarray ? "[" str "]" : "{" str "}"
	}
	else if obj is Number
		return obj
	StringReplace, obj, obj, \, \\, A
	StringReplace, obj, obj, % Chr(08), \b, A
	StringReplace, obj, obj, % A_Tab, \t, A
	StringReplace, obj, obj, `n, \n, A
	StringReplace, obj, obj, % Chr(12), \f, A
	StringReplace, obj, obj, `r, \r, A
	StringReplace, obj, obj, ", \", A
	StringReplace, obj, obj, /, \/, A
	while RegexMatch(obj, "[^\x20-\x7e]", key)
	{
		str := Asc(key)
		val := "\u"
			. Chr(((str >> 12) & 15) + (((str >> 12) & 15) < 10 ? 48 : 55))
			. Chr(((str >> 8) & 15) + (((str >> 8) & 15) < 10 ? 48 : 55))
			. Chr(((str >> 4) & 15) + (((str >> 4) & 15) < 10 ? 48 : 55))
			. Chr((str & 15) + ((str & 15) < 10 ? 48 : 55))
		StringReplace, obj, obj, % key, % val, A
	}
	obj := """" obj """"
	if RegExMatch(obj, "i)""\![a-z]+""")
	{
		StringReplace, obj, obj, "!true", true
		StringReplace, obj, obj, "!false", false
		StringReplace, obj, obj, "!null", null
	}
	return obj
}
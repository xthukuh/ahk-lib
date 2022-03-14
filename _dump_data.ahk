;dump data
_dump_data(data, _name := ""){
	s := xtrim(_name " dump object:")
	if isObject(data)
	{
		for key, val in data
		{
			val := isObject(val) ? xjson_encode(val) : (xis_num(val) ? val : """" val """")
			s .= "`n" key "= " val
		}
	}
	else {
		val := data
		val := isObject(val) ? xjson_encode(val) : (xis_num(val) ? val : """" val """")
		s := xtrim(_name " dump value: " val)
	}
	return s
}

;requires
#Include *i %A_LineFile%\..\xnum.ahk
#Include *i %A_LineFile%\..\xtrim.ahk
#Include *i %A_LineFile%\..\xjson_encode.ahk
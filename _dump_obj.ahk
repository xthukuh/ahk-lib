;includes
#Include *i %A_LineFile%\..\xtrim.ahk

;dump object
_dump_obj(o, sp := ""){
	s =
	if IsObject(o)
	{
		for k, v in o
			s .= sp k ":" (isObject(v) ? "`n" : " ") _dump_obj(v, sp "  ") "`n"
	}
	else s .= xtrim(o)
	return s
}
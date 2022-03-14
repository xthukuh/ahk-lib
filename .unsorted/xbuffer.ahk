xbuffer(ByRef var := "", _append := "", _join := "`n", _trim := true){
	global __xbuffer_join
	if __xbuffer_join !=
		_join := __xbuffer_join
	if xempty(_append := (_trim ? xtrim(_append, true) : _append))
		return var
	if isObject(var)
		var.Insert(_append)
	else var .= StrLen(var) ? _join _append : _append
	return var
}

#Include <xempty>
#Include <xtrim>
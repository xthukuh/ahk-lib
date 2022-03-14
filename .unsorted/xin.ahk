xin(needle, haystack, delimiter := ",", _trim := false){
	if isObject(haystack)
		return __xin_object_0000(needle, haystack)
	if xtrim(delimiter)
	{
		if isObject(haystack := xdsv(haystack, delimiter,,, _trim)[1])
			return __xin_object_0000(needle, haystack)
		return false
	}
	if (pos := InStr(haystack, needle))
		return pos
	return false
}

__xin_object_0000(needle, haystack){
	for key, item in haystack
		if xmatches(needle, item, _trim)
			return key
	return false
}

#Include <xmatches>
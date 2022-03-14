xcontains(haystack, needles, delimiter := ",", _trim := true, _all := false){
	found := 0, missed := 0
	if isObject(needles)
	{
		found := __xcontains_object_0000(needles, haystack, delimiter, _trim, missed)
		return found ? (_all ? (!missed ? found : false) : found) : false
	}
	if xtrim(delimiter)
	{
		if isObject(needles := xdsv(needles, delimiter,,, _trim)[1])
		{
			found := __xcontains_object_0000(needles, haystack, delimiter, _trim, missed)
			return found ? (_all ? (!missed ? found : false) : found) : false
		}
		return false
	}
	return InStr(haystack, needles)
}

__xcontains_object_0000(needles, haystack, delimiter := ",", _trim := false, ByRef missed := 0){
	found := 0, missed := 0
	for key, needle in needles
	{
		if xin(needle, haystack, delimiter, _trim)
			found ++
		else missed ++
	}
	return found
}

#Include <is_array>
#Include <xin>
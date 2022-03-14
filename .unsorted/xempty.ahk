xempty(ByRef val, _trim := true){
	if isObject(val)
		return !val.Count()
	if val is number
		return false
	return !StrLen(val := _trim ? RegExReplace(val, "^\s*|\s*$") : val)
}
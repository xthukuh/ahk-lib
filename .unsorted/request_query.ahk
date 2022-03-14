request_query(data, prop := ""){
	buffer =
	if xempty(data)
		return buffer
	if isObject(data)
	{
		for key, val in data
		{
			key := urlencode(key)
			val := isObject(val) ? request_query(val, key) : urlencode(val)
			pair := (prop != "" ? prop "[" key "]" : key) "=" val
			xbuffer(buffer, pair, "&")
		}
	}
	else {
		data := RegExReplace(data, "^\s*\?")
		pairs := StrSplit(data, "&")
		for i, pair in pairs
		{
			if !(pair := xtrim(pair))
				continue
			parts := StrSplit(pair, "=")
			pair := urlencode(xtrim(parts[1])) "=" urlencode(parts[2])
			xbuffer(buffer, pair, "&")
		}
	}
	return buffer
}

#Include <xempty>
#Include <xbuffer>
#Include <urlencode>
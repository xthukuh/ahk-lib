request_headers(headers_data := "", ByRef track := ""){
	headers := Object(), track := Object()
	if (isObject(headers_data) && headers_data.Count())
	{
		for key, val in headers_data
			__request_header_add(key, val, track, headers)
	}
	else if (!isObject(headers_data) && StrLen(items := xtrim(headers_data)))
	{
		header_key := "", header_value := ""
		loop, parse, items, `n
		{
			if !(item := xtrim(A_LoopField))
				continue
			if !(p := InStr(item, ":"))
			{
				header_value .= (header_value == "" ? "" : "`n") item
				continue
			}
			if !(key := xtrim(SubStr(item, 1, p - 1)))
			{
				header_value .= (header_value == "" ? "" : "`n") item
				continue
			}
			if (header_key != "" && header_value != "")
			{
				__request_header_add(header_key, header_value, track, headers)
				header_key := "", header_value := ""
			}
			header_key := key, header_value := xtrim(SubStr(item, p + 1))
		}
		if (header_key && header_value)
		{
			__request_header_add(header_key, header_value, track, headers)
			header_key := "", header_value := ""
		}
	}
	return headers
}

__request_header(ByRef key, ByRef value, ByRef track := ""){
	if (IsObject(value) && value.HasKey("key") && value.HasKey("value"))
	{
		key := value.key
		value := value.value
	}
	if !(StrLen(key := xtrim(key)) && StrLen(value := xtrim(value)))
		return
	if key is number
		return
	if (isObject(track) && track.HasKey(key) && track[key] == value)
		return
	return {key: key, value: value}
}

__request_header_add(key, value, ByRef track := "", ByRef headers := ""){
	if !IsObject(header := __request_header(key, value))
		return
	if IsObject(track)
		track[key] := value
	if IsObject(headers)
		headers.Insert(header)
}

#Include <xtrim>
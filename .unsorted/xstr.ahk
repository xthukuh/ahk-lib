xstr(value, _trim := false, _to_json := false, _to_csv := false){
	if xempty(value, _trim)
		return
	if IsObject(value)
	{
		if (_to_csv && is_array(value))
			return array_csv(value)
		if _to_json
			return json_create(value)
	}
	if value is Integer
		return Format("{:d}", value)
	if value is float
		return Format("{:f}", value)
	return value
}

qstr(value, _trim := false){
	return """" xstr(value, _trim) """"
}

#Include <xempty>
#Include <is_array>
#Include <array_csv>
#Include <json_create>
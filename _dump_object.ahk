;dump object
_dump_object(value, _space := "", _space_chars := "  ", ByRef _has_object := 0){
	_has_object := 0
	if isObject(value)
	{
		;check size
		if !(max_index := value.Count())
			return "{}"
		
		;check if array
		is_array := 1
		for k, v in value
		{
			if (k != A_Index)
			{
				is_array := 0
				break
			}
		}

		;buffer key, val
		_buffer := is_array ? "[" : "{"
		for key, val in value
		{
			;vars
			i := A_Index
			if (!_has_object && isObject(val))
				_has_object := 1
			
			;recurse dump
			val := _dump_object(val, _space _space_chars, _space_chars, _val_object)
			
			;buffer add
			if !is_array
			{
				if _val_object
					_buffer .= "`n" _space
				_buffer .= key ": " val (i != max_index ? ", " : "")
			}
			else _buffer .= val (i != max_index ? ", " : "")
		}

		;buffer close
		if _val_object
			_buffer .= "`n" _space
		_buffer .= is_array ? "]" : "}"
	}
	else {
		if value is not number
			value := "'" value "'" ;add 'quotes' to strings
		_buffer := value
	}

	;result
	return _buffer
}
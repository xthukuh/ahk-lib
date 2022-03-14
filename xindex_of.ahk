;get index of value
xindex_of(value, object, ByRef _a_index := 0){
	_a_index := 0
	if isObject(object)
	{
		for key, val in object
		{
			i := A_Index
			if isObject(value)
			{
				if !isObject(val)
					continue
				tmp := {matches: 0, count: 0}
				for k, v in value
				{
					tmp.count += 1
					if (val.HasKey(k) && val[k] == v)
						tmp.matches += 1
				}

				;match found - object
				if (tmp.matches && tmp.matches == tmp.count)
				{
					_a_index := i
					return key
				}
			}

			;match found - non object
			else if (value == val)
			{
				_a_index := i
				return key
			}
		}
	}
}
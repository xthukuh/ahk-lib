;var is type
xis(value, type := ""){
	
	;supported types
	types := {integer: "integer"
		, float: "float"
		, number: "number"
		, digit: "digit"
		, xdigit: "xdigit"
		, alpha: "alpha"
		, upper: "upper"
		, lower: "lower"
		, alnum: "alnum"
		, space: "space"
		, time: "time"
		, object: "object"
		, xobject: "xobject"
		, array: "array"
		, xarray: "xarray"}
	
	;check support
	if types.HasKey(type)
	{
		;type
		type := types[type]

		;object/array
		if type in object,xobject,array,xarray
		{
			if isObject(value)
			{
				if (type == "object")
					return 1
				if (len := value.Count())
				{
					if (type == "xobject")
						return 1
					if (type == "array" || type == "xarray")
					{
						is_array := 1
						for k, v in value
						{
							if (A_Index != k)
							{
								is_array := 0
								break
							}
						}
						if is_array
							return 1
					}
				}
				else if (type == "array")
					return 1
			}
		}

		;default
		else if value is %type%
			return 1
	}
}
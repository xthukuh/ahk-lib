xmatches(a, b, _trim := true){
	a := _trim ? xtrim(a, true) : a
	b := _trim ? xtrim(b, true) : b
	if (xtype(a) != xtype(b))
		return false
	if (isObject(a) && isObject(b) && a.Count() == b.Count())
	{
		for key, val in a
		{
			if !(b.HasKey(key) && xmatches(val, b[key], _trim))
				return false
		}
		return true
	}
	return (a == b)
}

#Include <xtrim>
#Include <xtypes>
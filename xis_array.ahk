;validate array (returns length)
xis_array(val)
{
	if !isObject(val)
		return
	for key, v in val
	{
		if (key != A_Index)
			return
	}
	return val.Length()
}
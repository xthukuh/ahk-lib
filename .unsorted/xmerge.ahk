merge(values*){
	item := Object()
	loop, % values.Count()
		item := xxmerge(item, values[A_Index])
	return item
}

xmerge(values*){
	item := Object()
	loop, % values.Count()
		item := xxmerge(item, values[A_Index], false)
	return item
}

rmerge(values*){
	item := Object()
	loop, % values.Count()
		item := xxmerge(item, values[A_Index], true, true)
	return item
}

xrmerge(values*){
	item := Object()
	loop, % values.Count()
		item := xxmerge(item, values[A_Index], false, true)
	return item
}

xxmerge(item, value, _insert := true, _replace := false){
	item := xclone(item, true)
	if !isObject(value)
	{
		if StrLen(value)
			item.Insert(value)
		return item
	}
	temp := xclone(item)
	if value.Count()
	{
		xinsert := _insert && is_array(value)
		for key, val in value
		{
			if xinsert
				item.Insert(val)
			else if item.HasKey(key)
				item[key] := isObject(xval := item[key]) ? xxmerge(xval, val, _insert, _replace) : (_replace ? val : [xval, val])
			else item[key] := val
		}
	}
	return item
}

#Include <xclone>
#Include <is_array>
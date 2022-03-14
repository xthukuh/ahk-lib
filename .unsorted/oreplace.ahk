oreplace(item, value, _recurse := true, _insert := false){
	item := xclone(item)
	if (IsObject(value) && value.Count())
	{
		xinsert := _insert && is_array(value)
		for key, val in value
		{
			if xinsert
			{
				item.Insert(val)
				continue
			}
			val := item.HasKey(key) && isObject(val) && isObject(xval := item[key]) && _recurse ? oreplace(xval, val, _recurse, _insert) : val
			item[key] := val
		}
	}
	return item
}

#Include <xclone>
#Include <is_array>
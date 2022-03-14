xhas_keys(obj, keys*){
	if isObject(obj)
	{
		for i, key in keys
			if !obj.HasKey(key)
				return false
		return true
	}
	return false
}
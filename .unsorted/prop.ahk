prop_get(obj, tree*){
	if (isObject(obj) && tree.Count())
	{
		value := obj
		for i, key in tree
		{
			if (isObject(value) && value.HasKey(key))
				value := value[key]
			else return
		}
		return value
	}
}
prop_set(obj, value, tree*){
	if !(IsObject(obj) && (count := tree.Count()))
		return value
	_new := value, i := count
	while (i >= 1)
	{
		temp := Object()
		temp[tree[i]] := _new
		_new := temp
		i --
	}
	return oreplace(obj, _new)
}

#Include <oreplace>
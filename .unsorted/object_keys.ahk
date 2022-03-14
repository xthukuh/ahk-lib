;object keys
object_keys(obj){
	keys := []
	if isObject(obj)
	{
		for key, val in obj
			keys.Insert(key)
	}
	return keys
}
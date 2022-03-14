xclone(item, _inset := false){
	temp := Object()
	if isObject(item)
	{
		for key, val in item
			temp[key] := val
	}
	else if (_inset && StrLen(item))
		temp.Insert(item)
	return temp
}
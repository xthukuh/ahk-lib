;normalize path
xpath(path, dir := "", _backslash := true){
	static cache := Object()
	if !(path := xtrim(path))
		return
	cache_key := RegExReplace(path "|" dir "|" _backslash, "[\\\/]", "/")
	if cache.HasKey(cache_key)
		return cache[cache_key]
	if _backslash
		a := "\", b := "/"
	else a := "/", b := "\"
	path := rtrim(StrReplace(path, b, a), a)
	dir := xtrim(dir) ? xpath(dir, "", _backslash) : ""
	temp := [], x := 0
	loop, parse, path, %a%
	{
		part := xtrim(A_LoopField)
		if (!part || part == ".")
			continue
		if (part == "..")
		{
			if (c := temp.Count())
				temp.Pop()
			else x ++
		}
		else temp.Insert(part)
	}
	loop, % x
		temp.InsertAt(1, "..")
	path := xjoin(temp, a)
	if (InStr(path, "..") && dir)
		path := xpath(dir . a . path, "", _backslash)
	if (!path && dir)
		path := dir
	SplitPath, path,,,, name
	if (!xtrim(name) || RegExMatch(name, "[\\/:\*\?""\<\>\|]"))
		return 0
	return (cache[cache_key] := path)
}

#Include <xtrim>
#Include <xjoin>
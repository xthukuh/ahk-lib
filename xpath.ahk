/*
	Path Helper
	By Martin Thuku (2021-05-31 00:47:01)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
	
	Get valid full path.
	Sensitive to A_WorkingDir.
	Set _path_ext to enforce extension.
*/

xpath(_path, ByRef _error := "", _path_ext := "", _path_ext_replace := 1){
	static cache ;results cache

	;set vars
	_error := ""
	if (_path_ext := Trim(_path_ext, " .`t`r`n"))
		StringLower, _path_ext, _path_ext

	;normalize path
	path := Trim(RegExReplace(StrReplace(_path, "/", "\"), "\\\s*\\*", "\"), " `t`r`n")
	
	;return cached full path (without _path_ext)
	if (_path_ext == "" && isObject(cache) && cache.HasKey(path))
		return cache[path]

	;full path
	full := xpath_full(path)
	SplitPath, full, _basename, _dir, _ext, _name, _drive
	
	;update _ext, _basename
	StringLower, _ext, _ext
	if (_name != "" && _path_ext != "" && _path_ext != _ext)
	{
		;set _ext
		if _ext !=
		{
			if _path_ext_replace
				_ext := _path_ext
			else _ext .= "." _path_ext
		}
		else _ext := _path_ext
		
		;set basename
		_basename := _name "." _ext
	}

	;update full path
	full := _dir (SubStr(full, 0) == "\" ? "\" : "")
	if _basename !=
		full := RTrim(full, "\") (full != "" ? "\" : "") _basename
	
	;validate full path - check illegal chars
	if !RegExMatch(full, "i)^([a-z]:)?([^:\*\!\?""\<\>\|]*)$")
	{
		_error := "Path contains invalid characters. (" full ")"
		return
	}

	;cache full path
	if full !=
	{
		if !isObject(cache)
			cache := Object()
		cache[full] := full
	}

	;result
	return full
}

;full path
xpath_full(path){
	static cache ;results cache
	
	;trim path
	path := Trim(path, " `t`r`n")
	
	;return cached result
	if (isObject(cache) && cache.HasKey(path))
		return cache[path]
	
	;get full path name - https://www.autohotkey.com/boards/viewtopic.php?t=67050
	cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
    VarSetCapacity(res, cc * (A_IsUnicode ? 2 : 1))
    DllCall("GetFullPathName", "str", path, "uint", cc, "str", res, "ptr", 0, "uint")
    
	;result
	res := Trim(res, " `t`r`n")
	
	;cache result
	if res !=
	{
		if !isObject(cache)
			cache := Object()
		cache[res] := res
	}

	;result
	return res
}

;path exists
xpath_exists(path, ByRef _full_path := ""){
	if (_full_path := xpath(path))
		return FileExist(path)
}

;path split
xpath_split(path, ByRef _basename := "", ByRef _dir := "", ByRef _ext := "", ByRef _name := "", ByRef _drive := "", ByRef _error := ""){
	if !(path := xpath(path, _error, _ext))
		return
	SplitPath, path, _basename, _dir, _ext, _name, _drive
	return path
}
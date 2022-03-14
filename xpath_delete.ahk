;path delete (file or folder)
xpath_delete(path, dir_recurse := 0, ByRef _error := ""){
	if !(path := xpath(path, _error))
		return
	if (tmp := FileExist(path))
	{
		if InStr(tmp, "D") ;dir
			return xdir_delete(path, dir_recurse, _error)
		else return xfile_delete(path, _error)
	}
}

;requires
#Include *i %A_LineFile%\..\xdir.ahk
#Include *i %A_LineFile%\..\xfile.ahk
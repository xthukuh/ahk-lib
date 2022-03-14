/*
	File Helper
	By Martin Thuku (2021-05-31 22:32:26)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

;get file path
xfile(path, _mkdir := 0, ByRef _error := "", _path_ext := ""){
	if !(file := xpath(path, _error, _path_ext))
		return
	if _mkdir
	{
		SplitPath, file,, _dir
		if !xdir_create(_dir, _error)
			return
	}
	return file
}

;file append
xfile_append(str, path, _overwrite := 0, ByRef _error := "", _encoding := "", _disable_eol := 0){
	if !(file := xfile(path, _mkdir := 1, _error))
		return
	if (_overwrite && !xfile_delete(file, _error))
		return
	if _disable_eol
		file := "*" file
	FileAppend, % str, % file, % _encoding
	if !ErrorLeveL
		return 1
	_error := Trim("File append fail! (" file ") " A_LastError)
}

;file delete
xfile_delete(path, ByRef _error := ""){
	if !(file := xpath(path, _error))
		return
	if !xis_file(file)
		return -1
	FileDelete, % file
	if !ErrorLevel
		return 1
	_error := Trim("File delete fail! (" file ") " A_LastError)
}

;is file (file exists)
xis_file(path){
	return (path := Trim(path, " `t`r`n")) != ""
		&& (tmp := FileExist(path))
		&& !InStr(tmp, "D")
}

;requires
#Include *i %A_LineFile%\..\xpath.ahk
#Include *i %A_LineFile%\..\xdir.ahk
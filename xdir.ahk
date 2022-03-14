/*
	Dir Helper
	By Martin Thuku (2021-05-31 00:20:29)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

;get dir path
xdir(path, _mkdir := 0, ByRef _error := ""){
	if !(dir := xpath(path, _error))
		return
	return _mkdir ? xdir_create(dir, _error) : dir
}

;dir create if not exist
xdir_create(path, ByRef _error := ""){
	if !(dir := xpath(path, _error))
		return
	if xis_dir(dir)
		return dir
	FileCreateDir, % dir
	if !ErrorLeveL
		return dir
	_error := Trim("Dir create fail! (" dir ") " A_LastError)
}

;dir delete if exist
xdir_delete(path, recurse := 1, ByRef _error := ""){
	if !(dir := xpath(path, _error))
		return
	if !xis_dir(dir)
		return -1
	FileRemoveDir, % dir, % recurse
	if !ErrorLevel
		return 1
	if recurse
		_error := Trim("Dir delete fail! (" dir ") " A_LastError)
	else _error := Trim("Dir delete fail! The folder might not be empty. Try again with recurse enabled. (" dir ") " A_LastError)
}

;is dir (dir exists)
xis_dir(path){
	return (path := Trim(path, " `t`r`n")) != ""
		&& (tmp := FileExist(path))
		&& InStr(tmp, "D")
}

;requires
#Include *i %A_LineFile%\..\xpath.ahk
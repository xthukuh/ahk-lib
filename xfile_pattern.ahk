/*
	File Pattern Helper
	By Martin Thuku (2021-06-01 03:03:23)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

xfile_pattern(val, _mkdir := 0, ByRef _pattern_dir := "", ByRef _error := ""){
	;clear vars
	_pattern_dir := ""
	_error := ""
	_dir := ""
	
	;normalize val
	val := Trim(StrReplace(val, "/", "\"), " `t`r`n")
	
	;split pattern
	if (p := InStr(val, "\", _CaseSensitive := 0, _StartingPos := 0, _Occurrence := 1))
	{
		;pattern basename
		_basename := Trim(SubStr(val, p + 1), " `t`r`n")
		
		;pattern dir
		if ((_dir := Trim(SubStr(val, 1, p), " `t`r`n")) != "")
		{
			;check dir path
			if !(tmp := xpath(_dir, _error))
			{
				_error := Trim("Invalid file pattern! (" val ")`n" _error, " `t`r`n")
				return
			}
			_dir := tmp

			;mkdir
			if (_mkdir && !xdir_create(_dir, _error))
			{
				_error := Trim("File pattern dir could not be created! (" val ")`n" _error, " `t`r`n")
				return
			}
		}
	}
	else _basename := val ;pattern basename - default

	;normalized pattern
	_pattern_dir := RTrim(res := _dir, "\")
	if _basename !=
		res := _pattern_dir (res != "" ? "\" : "") _basename

	;result
	return res
}

;requires
#Include *i %A_LineFile%\..\xdir.ahk
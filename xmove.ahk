/*
	Move Helper
	By Martin Thuku (2021-06-01 01:09:31)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io

	;xmove(source_pattern, dest_pattern, _overwrite := 0, _folders := 1, _error)
	Returns failure count (ErrorLevel)
*/

xmove(source_pattern, dest_pattern, _overwrite := 1, _folders := 1, ByRef _error := ""){
	;vars
	_error := ""
	_error_count := 0

	;source
	source := xfile_pattern(source_pattern, _mkdir := 0, _pattern_dir, _error)
	if !(source && xis_dir(_pattern_dir))
	{
		_error := Trim("Source file pattern is invalid. (" source_pattern ")`n" _error, " `t`r`n")
		return
	}

	;destination
	dest := xfile_pattern(dest_pattern, _mkdir := 1, _dest_dir, _error)
	if !(dest && xis_dir(_dest_dir))
	{
		_error := Trim("Destination file pattern is invalid. (" dest_pattern ")`n" _error, " `t`r`n")
		return
	}

	;move files
	FileMove, % source, % dest, % (_overwrite ? 1 : 0)
	_error_count := ErrorLevel

	;move folders
	if _folders
	{
		loop, % source, 2
		{
			;dir
			dir := A_LoopFileFullPath
			dir_dest := _dest_dir "\" A_LoopFileName

			;move dir
			FileMoveDir, % dir, % dir_dest, % (_overwrite ? 2 : 0)
			_error_count += ErrorLevel
			
			;move dir error
			if ErrorLevel
			{
				_error .= (_error != "" ? "`n" : "") Trim("Move dir failed! (" dir " > " dir_dest ") " A_LastError)
				break
			}
		}
	}

	;result - failure count
	return _error_count
}

;requires
#Include *i %A_LineFile%\..\xfile_pattern.ahk

/*
	File Pattern List
	By Martin Thuku (2021-06-01 03:29:33)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

xfile_pattern_list(pattern
	, _include_folders := 0
	, _recurse := 0
	, _max_count := 0
	, _callback := ""
	, _callback_item := 0
	, _callback_skip := 1
	, _callback_break := -1
	, _include_empty := 0)
{
	;check pattern - ignore invalid
	if !(pattern := xfile_pattern(pattern))
		return
	
	;set vars
	items := []
	_max_count := _max_count * 1
	_callback := IsFunc(_callback) ? _callback : ""

	;loop file pattern
	loop, % pattern, % _include_folders, % _recurse
	{
		;item
		item := A_LoopFileFullPath
		
		;callback
		if _callback
		{
			res := %_callback%(item, A_Index)

			;skip
			if (res == _callback_skip)
				continue
			
			;break
			if (res == _callback_break)
				break

			;replace item
			if _callback_item
				item := res
		}

		;add item
		if (item != "" || _include_empty)
			items.Push(item)

		;max count break
		if (_max_count > 0 && items.Length() >= _max_count)
			break
	}

	;result
	return items
}

;requires
#Include *i %A_LineFile%\..\xfile_pattern.ahk
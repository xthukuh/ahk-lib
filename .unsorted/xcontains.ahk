xcontains(value, _match_list, _delim := ",", _case_sensitive := false, _trim := true){
	if ((value := _trim ? trim(value, " `t`r`n") : value) != "")
	{
		if !isObject(_match_list)
			_match_list := dsv(_match_list, _delim)
		if _match_list.Length()
		{
			for i, item in _match_list
				if ((item := _trim ? trim(item, " `t`r`n") : item) != "" && InStr(value, item, _case_sensitive))
					return true
		}
	}
}

;dsv
#Include <xdsv>
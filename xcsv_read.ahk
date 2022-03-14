;csv helper
xcsv_read(path, ByRef _columns := "", _header := 1, _lines := 0, _parse := "CSV"){
	if !xis_file(path)
		return
	
	;columns filter
	_cols := ""
	if (isObject(_columns) && _columns.Length())
	{
		loop, % _columns.Length()
		{
			if ((col := xtrim(_columns[A_Index])) != "")
				_cols .= (_cols != "" ? "," : "") col
		}
	}
	else if ((_columns := xtrim(_columns)) != "")
		_cols := _columns

	;read csv
	n := 0
	_rows := Object()
	_cols_map := Object()
	Loop
	{
		;line index
		i := A_Index

		;read csv line - break on error
		FileReadLine, line, % path, % i
		if ErrorLevel
			break

		;ignore empty line
		if !((line := xtrim(line)) != "")
			continue
		
		;count lines
		n += 1

		;lines limit (includes cols)
		if (_lines > 0 && n > _lines)
			break
		
		;csv columns
		if (n == 1 && _header)
		{
			loop, parse, line, % _parse
			{
				;col index
				c := A_Index

				;ignore empty
				if !((val := xtrim(A_LoopField)) != "")
					continue
				
				;filter cols
				if _cols !=
				{
					if val not in % _cols
					{
						if c not in % _cols
							continue
					}
				}

				;col map
				_cols_map[c] := val
			}

			;break no columns
			if !_cols_map.Count()
				break
			
			;next
			continue
		}

		;csv row
		_row_map := Object()
		loop, parse, line, % _parse
		{
			;col vars
			col := ""
			c := A_Index
			val := xtrim(A_LoopField)
			
			;filter row cols
			if (isObject(_cols_map) && _cols_map.Count())
			{
				;ignore filtered
				if !_cols_map.HasKey(c)
					continue
				
				;set col name
				col := _cols_map[c]

				;row map
				_row_map[col] := val
			}
			else _row_map[c] := val
		}

		;rows add
		if _row_map.Count()
			_rows.Push(_row_map)
	}

	;update column names list
	_columns := []
	if (c := _cols_map.Count())
	{
		for k, val in _cols_map
			_columns.Push(val)
	}

	;result data
	return {columns: _columns, map: _cols_map, rows: _rows}
}

;requires
#Include *i %A_LineFile%\..\xtrim.ahk
#Include *i %A_LineFile%\..\xfile.ahk
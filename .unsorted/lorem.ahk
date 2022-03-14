;lorem.txt
lorem_file(){
	file := A_LineFile
	StringReplace, file, file, /, \
	path := SubStr(file, 1, (i := InStr(file, "\",, 0)) > 1 ? i : "") "\lorem.txt"
	IfNotExist, % path
		Throw, "Lorem file does not exist! " path
	return path
}

;random index
lorem_rand(max, Byref _seen := ""){
	_seen := IsObject(_seen) ? _seen : {}
	loop, % max
	{
		Random, rand, 1, %max%
		if !_seen.HasKey(rand)
		{
			_seen[rand] := rand
			break
		}
	}
	return rand
}

;string buffer (mode == 1)
lorem_buf(buf, _size){
	return Trim(SubStr(buf, 1, _size))
}

;read lorem.txt
lorem(_size, _mode := 0, _join := " ", _rand := 0, Byref _lines := ""){
	static xlines := []
	_lines := xlines
	if ((_size := Abs(_size * 1)) < 1)
		return
	if !xlines.Length()
	{
		file := lorem_file()
		loop
		{
			FileReadLine, line, %file%, %A_Index%
			if ErrorLevel
				break
			line := Trim(line, " `r`n`t")
			if line !=
				xlines.Insert(line)
		}
		_lines := xlines
	}
	if !(len := xlines.Length())
		Throw, "Lorem file might be empty! " file
	x := 0
	buf := ""
	loop, % len
	{
		x ++
		i := _rand ? lorem_rand(len, _seen) : A_Index
		buf .= (buf != "" ? _join : "") xlines[i]
		if (_mode == 1 && Strlen(lorem_buf(buf, _size)) >= _size)
			break
		else if (x >= _size)
			break
	}
	return _mode == 1 ? lorem_buf(buf, _size) : buf
}

;lorem pragraph
lorem_p(_count := 1, _rand := 1, _join := "`n"){
	return lorem(_count, _mode := 0, _join, _rand)
}

;lorem string
lorem_s(_len := 100, _rand := 1, _join := " "){
	return lorem(_len, _mode := 1, _join, _rand)
}
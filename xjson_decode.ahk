xjson_decode(str, mode := 0){
	quot := """"
	ws := "`t`n`r " Chr(160)
	obj := {}
	objs := []
	keys := []
	isarrays := []
	literals := []
	y := nest := 0
	StringGetPos, z, str, %quot% ; initial seek
	while !ErrorLevel
	{
		StringGetPos, x, str, %quot%,, % z + 1
		while !ErrorLevel
		{
			StringMid, key, str, z + 2, x - z - 1
			StringReplace, key, key, \\, \u005C, A
			If SubStr(key, 0) != "\"
				break
			StringGetPos, x, str, %quot%,, % x + 1
		}
		str := (z ? SubStr(str, 1, z) : "") quot SubStr(str, x + 2)
		StringReplace, key, key, \%quot%, %quot%, A
		StringReplace, key, key, \b, % Chr(08), A
		StringReplace, key, key, \t, % A_Tab, A
		StringReplace, key, key, \n, `n, A
		StringReplace, key, key, \f, % Chr(12), A
		StringReplace, key, key, \r, `r, A
		StringReplace, key, key, \/, /, A
		while y := InStr(key, "\u", 0, y + 1)
		{
			if (A_IsUnicode || Abs("0x" SubStr(key, y + 2, 4)) < 0x100)
				key := (y = 1 ? "" : SubStr(key, 1, y - 1)) Chr("0x" SubStr(key, y + 2, 4)) SubStr(key, y + 6)
		}
		literals.insert(key)
		StringGetPos, z, str, %quot%,, % z + 1 ; seek
	}
	key := isarray := 1
	loop, parse, str, % "]}"
	{
		StringReplace, str, A_LoopField, [, [], A
		loop, parse, str, % "[{"
		{
			if (A_Index != 1)
			{
				objs.insert(obj)
				isarrays.insert(isarray)
				keys.insert(key)
				obj := {}
				isarray := key := Asc(A_LoopField) = 93
			}
			if (isarray)
			{
				loop, parse, A_LoopField, `,, % ws "]"
				{
					if (A_LoopField != "")
					{
						val := A_LoopField = quot ? literals.remove(1) : A_LoopField
						val := __json_decode_val(val, A_LoopField, mode)
						obj[key++] := val
					}
				}
			}
			else {
				loop, parse, A_LoopField, `,
				{
					loop, parse, A_LoopField, :, % ws
					{
						if (A_Index = 1)
						{
							key := A_LoopField = quot ? literals.remove(1) : A_LoopField
						}
						else if (A_Index = 2 && A_LoopField != "")
						{
							val := A_LoopField = quot ? literals.remove(1) : A_LoopField
							val := __json_decode_val(val, A_LoopField, mode)
							obj[key] := val
						}
					}
				}
			}
			nest += A_Index > 1
		}
		if !--nest
			break
		pbj := obj
		obj := objs.remove()
		obj[key := keys.remove()] := pbj
		if (isarray := isarrays.remove())
			key ++
	}
	return obj
}

__json_decode_val(val, pval, mode){
	if !RegExMatch(pval, "[^a-z]")
	{
		tmp := Trim(val, " `n`t")
		StringLower, tmp, tmp
		if (tmp == "true")
			val := mode == 1 ? "!true" : true
		if (tmp == "false")
			val := mode == 1 ? "!false" : false
		if (tmp == "null")
			val := mode == 1 ? "!null" : ""
	}
	return val
}
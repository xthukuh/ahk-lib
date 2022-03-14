;join array items to string
xjoin(items, glue := " "){
	str =
	if (is_array(items) && (count := items.Count()))
	{
		gitems := is_array(glue) ? glue : [glue], glue := ""
		if !(gcount := gitems.Count())
		{
			gitems := [""]
			gcount := 1
		}
		loop, % count
		{
			i := A_Index
			xbuffer(str, items[i], gitems[xoffset(i - 1, gcount, true)])
		}
	}
	return str
}

#Include <is_array>
#Include <xoffset>
#Include <xbuffer>
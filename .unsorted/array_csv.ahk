array_csv(value, _trim := false){
	csv =
	if is_array(value)
	{
		loop, % value.Count()
		{
			item := value[A_Index]
			if !is_array(item)
			{
				item := _trim ? xtrim(item) : item
				if RegExMatch(item, "["",\n]")
					item := """" item """"
				xbuffer(csv, item, ",", _trim)
			}
			else xbuffer(csv, array_csv(item), "`n", _trim)
		}
	}
	return csv
}

#Include <is_array>
#Include <xtrim>
#Include <xbuffer>
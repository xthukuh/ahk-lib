;splice array
xsplice(arr, offset, length := 0){
	items := []
	if (is_array(arr) && (count := arr.Count()))
	{
		offset := xint(offset)
		if (offset < 0 && Abs(offset) > count)
			return items
		index := xoffset(offset, count), length := aint(length)
		loop
		{
			if (index > count || (length != 0 && items.Count() == length))
				break
			items.Insert(arr[index])
			index ++
		}
	}
	return items
}

#Include <xint>
#Include <xoffset>
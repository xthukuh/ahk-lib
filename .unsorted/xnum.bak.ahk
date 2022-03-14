xnum(value, _default := ""){
	num := _default
	if ((value := xtrim(value)) != "")
	{
		if RegExMatch(value, "^(?!0+\.00)(?=.{1,9}(\.|$))(?!0(?!\.))\d{1,3}(,\d{3})*(\.\d+)?$")
			value := RegExReplace(value, "[^0-9\.]")
		if value is number
		{
			if value is float
			{
				if (p := instr(value, "."))
				{
					w := substr(value, 1, p - 1)
					d := rtrim(substr(value, p + 1, 15), "0")
					w := w == "" ? 0 : w * 1
					num := d != "" ? w "." d : w
				}
			}
			num := value * 1
		}
	}
	return num
}
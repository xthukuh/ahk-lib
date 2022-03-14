xcolor(val){
	static color_names := {Black: "000000"
		, Silver: "C0C0C0"
		, Gray: "808080"
		, White: "FFFFFF"
		, Maroon: "800000"
		, Red: "FF0000"
		, Purple: "800080"
		, Fuchsia: "FF00FF"
		, Green: "008000"
		, Lime: "00FF00"
		, Olive: "808000"
		, Yellow: "FFFF00"
		, Navy: "000080"
		, Blue: "0000FF"
		, Teal: "008080"
		, Aqua: "00FFFF"}
	col := "", name := "", val := trim(val, " `t`r`n")
	if val !=
	{
		if color_names.HasKey(val)
		{
			col := color_names[val]
			name := Format("{:T}", val)
		}
		else if RegExMatch(val, "Oi)^#?([0-9a-f]{3}|[0-9a-f]{6})$", matches)
			col := Format("{:U}", StrLen(col := matches[1]) == 6 ? col : RegExReplace(col, "([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])", "$1$1$2$2$3$3"))
	}
	if col !=
	{
		hex := "0x" col
		
		R := (hex & 0xFF0000) >> 16
		G := (hex & 0xFF00) >> 8
		B := hex & 0xFF
		lum := floor(0.2126 * R + 0.7152 * G + 0.0722 * B)
		
		rgb := "(" R "," G "," B ")"
		rgb.base.arr := [R, G, B]
		rgb.base.obj := {R: R, G: G, B: B}
		
		col.base.name := name
		col.base.hex := hex
		col.base.rgb := rgb
		col.base.lum := lum
	}
	return col
}
;tooltip notify function
xtooltip(message, timeout := 2000, x := 0, y := 0, which := 1){
	if strlen(message := RegExReplace(message, "^\s*|\s*$"))
	{
		if x > 0 && y > 0
		{
			if which > 1 && which <= 20
				ToolTip,%message%,%x%,%y%,%which%
			else ToolTip,%message%,%x%,%y%
		}
		else {
			if which > 1 && which <= 20
				ToolTip,%message%,,,%which%
			else ToolTip,%message%
		}
		if timeout > 0
		{
			fn := Func("xtooltip_hide")
			fn.Bind(which)
			SetTimer, %fn%, -%timeout%
		}
	}
	else xtooltip_hide()
}
;tooltip hide
xtooltip_hide(which := 1){
	if which > 1 && which <= 20
		ToolTip,,,,%which%
	else ToolTip
}
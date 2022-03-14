;includes
#Include *i %A_LineFile%\..\..\xnum.ahk
#Include *i %A_LineFile%\..\xgui_helper.ahk

;xgui helper - status bar
class xgui_helper_sb
{
	;new instance
	__New(gui_helper)
	{
		this._gui_helper := gui_helper
		this._parts := []
	}

	;get gui helper
	gui(throwable := true)
	{
		if xgui_helper.is_instance(gui_helper := this._gui_helper)
			return gui_helper
		if throwable
			throw "Invalid " this.__class " gui helper instance."
	}

	;set parts << self
	set_parts(widths*)
	{
		this._parts := []
		for i, w in widths
			this._parts.Push(anum(w))
		this.gui().default()
		SB_SetParts(this._parts*)
		return this
	}

	;get parts count
	parts()
	{
		return (isObject(this._parts) ? this._parts.Length() : 0) + 1
	}

	;get part number - default = parts count (right most)
	part(part := 0)
	{
		parts := this.parts()
		return (part := aint(part)) >= 1 && part <= parts ? part : parts
	}

	;set icon
	set_icon(file_name, icon_number := "", part := 0)
	{
		this.gui().default()
		SB_SetIcon(file_name, icon_number, this.part(part))
		return this
	}

	;set text
	set_text(text := "", part := 0, style := 0)
	{
		if style not in 0,1,2
			style := 0
		parts := this.parts()
		part := this.part(part)
		if (part == parts)
			text := RTrim(text) "     "
		this.gui().default()
		SB_SetText(text, this.part(part), style)
		return this
	}
}
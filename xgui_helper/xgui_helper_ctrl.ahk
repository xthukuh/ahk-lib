;includes
#Include *i %A_LineFile%\..\..\xtrim.ahk
#Include *i %A_LineFile%\..\xgui_helper.ahk
#Include *i %A_LineFile%\..\xgui_helper_cls.ahk

;xgui helper - control
class xgui_helper_ctrl extends xgui_helper_cls
{
	;statics
	static _types := {Text: "Text"
		, Edit: "Edit"
		, UpDown: "UpDown"
		, Picture: "Picture"
		, Button: "Button"
		, Checkbox: "Checkbox"
		, Radio: "Radio"
		, DropDownList: "DropDownList"
		, ComboBox: "ComboBox"
		, ListBox: "ListBox"
		, ListView: "ListView"
		, TreeView: "TreeView"
		, Link: "Link"
		, Hotkey: "Hotkey"
		, DateTime: "DateTime"
		, MonthCal: "MonthCal"
		, Slider: "Slider"
		, Progress: "Progress"
		, GroupBox: "GroupBox"
		, Tab: "Tab"
		, Tab2: "Tab2"
		, Tab3: "Tab3"
		, StatusBar: "StatusBar"
		, ActiveX: "ActiveX"
		, Custom: "Custom"}

	;new instance
	__New(gui_helper, type, options := "", text := "", grow := "")
	{
		;properties
		this._gui_helper := gui_helper
		this._type := type
		this._options := options
		this._text := text
		this._grow := grow

		;gui add ctrl
		this.add()
	}

	;get gui helper
	gui(throwable := true)
	{
		if xgui_helper.is_instance(gui_helper := this._gui_helper)
			return gui_helper
		if throwable
			throw "Invalid " this.__class " gui helper instance."
	}

	;get type
	type()
	{
		type := xtrim(this._type)
		types := this.base._types
		if (type != "" && types.HasKey(type))
			return types[type]
		throw "Invalid " this.class_name() " type name """ type """."
	}

	;get options
	options(ByRef name := "")
	{
		name := ""
		options := xtrim(this._options)
		if (options == "")
			return
		loop, parse, options, % A_Space
		{
			opt := xtrim(A_LoopField)
			if RegExMatch(opt, "iO)^v([^\s]+)", matches)
			{
				if ((tmp := xtrim(matches[1])) != "")
				{
					name := tmp
					break
				}
			}
		}
		return options
	}

	;get text
	text()
	{
		if isObject(this._text)
			this._text := ""
		return this._text
	}

	;get/set grow
	grow(grow := "")
	{
		if ((grow := xtrim(grow)) != "")
			this._grow := grow
		return xtrim(this._grow)
	}

	;gui add
	add()
	{
		global
		local _gui, _type, _opts, _text, _name, _id, _tmp
		_gui := this.gui().name()
		_type := this.type()
		_opts := this.options(_name)
		_text := this.text()
		_opts_name := _name != ""
		_name := this.new_instance(_name, _type)
		this.gui().default()
		if !_opts_name
			Gui, %_gui%: Add, %_type%, %_opts% v%_name%, %_text%
		else
			Gui, %_gui%: Add, %_type%, %_opts%, %_text%
		GuiControlGet, _id, Hwnd, %_name%
		/*
		s =
		if !_opts_name
			s = Gui, %_gui%: Add, %_type%, %_opts% v%_name%, %_text%
		else
			s = Gui, %_gui%: Add, %_type%, %_opts%, %_text%
		xmsg(s "`n_id: " _id "`n_name: " this.name())
		*/
		this.set_id(_id)
	}

	;ctrl pos - GuiControlGet, Pos << {x, y, w, h} | _list > [x, y, w, h]
	pos(_list := 0)
	{
		if !(id := this.id())
			return
		if !(name := this.name())
			return
		GuiControlGet, pos_, Pos, %name%
		x := pos_x
		y := pos_y
		w := pos_w
		h := pos_h
		;ControlGetPos, x, y, w, h,, ahk_id %id%
		return _list ? [x, y, w, h] : {x: x, y: y, w: w, h: h}
	}

	;ctrl get - GuiControlGet << output
	get(cmd := "", value := "")
	{
		if !(name := this.name())
			return
		this.gui().default()
		GuiControlGet, output, %cmd%, %name%, %value%
		return output
	}

	;ctrl set - GuiControl << self
	set(cmd := "", value := "")
	{
		if !(name := this.name())
			return this
		this.gui().default()
		GuiControl, %cmd%, %name%, %value%
		return this
	}

	;ctrl move - Move|MoveDraw << self
	move(pos, _draw := 0)
	{
		if ((pos := xtrim(pos)) == "")
			return this
		cmd := _draw ? "MoveDraw" : "Move"
		return this.set(cmd, pos)
	}
}
Gui, _main_: Menu, _main_menu_
Gui, _main_: Add, ListView, x2 y2 w640 h420 +Grid v_list, #|Item Title|Price|Creator|Status|Timestamp
Gui, _main_: Add, Button, x442 y439 w210 h40 v_start g_start, Start
Gui, _main_: Add, Progress, x12 y429 w640 h10 v_marquee,
Gui, _main_: Add, StatusBar,,
Gui, _main_: Show, w663 h510, % app

#Include <xtrim>
#Include <xnum>
#Include <xthrow>

class gui_builder extends class_config {
	__config_default := {name: 1
		, title: "Untitled"
		, owner: ""
		, options: ""
		, created: false
		, modal: false
		, on_close: ""
		, on_escape: ""
		, on_resize: ""
		, menu: ""
		, color: ""
		, margin: ""
		, items: {}}
	created {
		get {
			return !!this.config.created
		}
		set {
			return this.config.created := !!value
		}
	}
	name {
		get {
			name := this.config.name
			name := name != "" ? name : 1
			return name
		}
		set {
			value := xtrim(value)
			if value !=
			{
				if value is not number
				if InStr(value, ":")
					value := xtrim(StrReplace(value, ":"))
			}
			value := value != "" ? value : 1
			this.config.name := value
		}
	}
	id {
		get {
			id := ""
			if this.created
			{
				name := this.name
				Gui, %name%: +HWND_hwnd
				id := _hwnd
			}
			return id
		}
	}
	title {
		get {
			return this.config.title
		}
		set {
			value := xtrim(value)
			if (id := this.id) !=
				WinSetTitle, ahk_id %id%,, %value%
			return this.config.title := value
		}
	}
	modal {
		get {
			return !!this.config.modal
		}
		set {
			return this.config.modal := !!value
		}
	}
	owner {
		get {
			return this.config.owner
		}
		set {
			return this.config.owner := xtrim(value)
		}
	}
	options {
		get {
			return this.config.options
		}
		set {
			return this.config.options := xtrim(value)
		}
	}
	showing {
		get {
			showing := false
			if (id := this.id) !=
			{
				a_detect := A_DetectHiddenWindows
				DetectHiddenWindows, Off
				showing := !!WinExist("ahk_id " id)
				DetectHiddenWindows, %a_detect%
				a_detect =
			}
			return showing
		}
	}
	exists {
		get {
			exists := false
			if (id := this.id) !=
			{
				a_detect := A_DetectHiddenWindows
				DetectHiddenWindows, On
				exists := !!WinExist("ahk_id " id)
				DetectHiddenWindows, %a_detect%
				a_detect =
			}
			return exists
		}
	}
	pos(key := "", _reset := false){
		if (id := this.id) !=
		{
			if (_reset || !isObject(pos := this.config.pos))
			{
				WinGetPos, x, y, sw, sh, ahk_id %id%
				VarSetCapacity(rect, 16, 0)
				DllCall("GetClientRect", "UInt", id, "UInt", &rect)
				w := NumGet(rect, 8, "Int")
				h := NumGet(rect, 12, "Int")
				pos := (this.config.pos := {x: x, y: y, w: w, h: h, sw: sw, sh: sh})
			}
			if (key := xtrim(key)) !=
				return pos.HasKey(key) ? pos[key] : ""
			return pos
		}
	}
	pos {
		get {
			return this.pos()
		}
		set {
			return this.pos("", true)
		}
	}
	x {
		get {
			return this.pos("x")
		}
	}
	y {
		get {
			return this.pos("y")
		}
	}
	w {
		get {
			return this.pos("w")
		}
	}
	h {
		get {
			return this.pos("h")
		}
	}
	on_close {
		get {
			return this.config.on_close
		}
		set {
			return this.config.on_close := value
		}
	}
	on_escape {
		get {
			return this.config.on_escape
		}
		set {
			return this.config.on_escape := value
		}
	}
	on_resize {
		get {
			return this.config.on_resize
		}
		set {
			return this.config.on_resize := value
		}
	}
	menu {
		get {
			menu := xtrim(this.config.menu)
			return MenuGetHandle(menu) ? menu : ""
		}
		set {
			return this.config.menu := xtrim(value)
		}
	}
	color {
		get {
			color := this.config.color
			return color && isObject(color) && color.HasKey("window") && color.HasKey("control") ? color : ""
		}
		set {
			if !isObject(value)
			{
				if (temp := xtrim(value)) !=
				{
					value := {window: "", control: ""}
					loop, parse, temp, `,
					{
						col := xtrim(A_LoopField)
						if A_Index = 1
							value.window := col
						else if A_Index = 2
							value.control := col
						else break
					}
				}
				else value =
				temp =
			}
			color =
			if (value && isObject(value) && (value.HasKey("window") || value.HasKey("control")))
			{
				color := isObject(color := this.config.color) ? color : {}
				if value.HasKey("window")
					color.window := xtrim(value.window)
				if value.HasKey("control")
					color.control := xtrim(value.control)
				value =
				if this.created
					this.gui("Color", color.window, color.control)
			}
			return this.config.color := color
		}
	}
	color_window {
		get {
			return isObject(color := this.color) && color.HasKey("window") && (col := xtrim(color.window)) != "" ? col : ""
		}
		set {
			return (value := xtrim(value)) != "" ? (this.color := {window: value}) : ""
		}
	}
	color_control {
		get {
			return isObject(color := this.color) && color.HasKey("control") && (col := xtrim(color.control)) != "" ? col : ""
		}
		set {
			return (value := xtrim(value)) != "" ? (this.color := {control: value}) : ""
		}
	}
	margin {
		get {
			margin := this.config.margin
			return margin && isObject(margin) && margin.HasKey("x") && margin.HasKey("y") ? margin : ""
		}
		set {
			if !isObject(value)
			{
				if (temp := xtrim(value)) !=
				{
					value := {}
					loop, parse, temp, `,
					{
						val := xnum(A_LoopField, "")
						if A_Index = 1
							value.x := val
						else if A_Index = 2
							value.y := val
					}
				}
				else value =
				temp =
			}
			margin =
			if (value && isObject(value) && (value.HasKey("x") || value.HasKey("y")))
			{
				margin := isObject(margin := this.config.margin) ? margin : {}
				if value.HasKey("x")
					margin.x := xnum(value.x, "")
				if value.HasKey("y")
					margin.y := xnum(value.y, "")
				value =
				if this.created
					this.gui("Margin", margin.x, margin.y)
			}
			return this.config.margin := margin
		}
	}
	items {
		get {
			items := this.config.items
			return IsObject(items) ? items : (this.config.items := {})
		}
		set {
			value := IsObject(value) ? value : {}
			return this.config.items := value
		}
	}
	__New(_name := 1, _options := ""){
		this.name := _name
		this.options := _options
		this.created := false
	}
	font(_font := "Norm", _options := ""){
		font_name =
		font_options =
		if (_font := xtrim(_font)) !=
		{
			if (_font = "norm")
				font_options .= " Norm"
			else font_name := _font
		}
		if isObject(_options)
		{
			for key, val in _options
			{
				if ((val := xtrim(val)) == "" || !RegExMatch(val, "i)^[a-z0-9 ]+$"))
					continue
				key := Format("{:L}", xtrim(key)), opt := ""
				if key is integer
					opt := val
				else if (key = "name" || key = "font")
				{
					font_name := val
					continue
				}
				else if key = size
					opt := (val := xnum(ltrim(val, "s"), "")) != "" ? "s" val : ""
				else if key = color
					opt := "c" val
				else if key = weight
				{
					if (val := xnum(ltrim(val, "w"), "")) !=
					{
						if (val >= 1 && val <= 1000)
							opt := "w" val
					}
				}
				else if (key = "styles" || key = "style")
					opt := val
				else if (key = "q" || key = "quality")
				{
					if (val := xnum(ltrim(val, "q"), "")) !=
					{
						if (val >= 0 && val <= 5)
							opt := "q" val
					}
				}
				if opt =
					continue
				font_options .= " " opt
			}
		}
		else if ((_options := xtrim(_options)) != "" && RegExMatch(_options, "i)^[a-z0-9 ]+$"))
			font_options .= _options
		font_name := trim(font_name)
		font_options := trim(font_options)
		if (font_name == "" && font_options == "")
			font_options := "Norm"
		item := {type: "font", value: {name: font_name, options: font_options}}
		this.items.push(item)
		if this.created
			this.gui("Font", item.value.options, item.value.name) ;Gui, Font [, Options, FontName]
		return this
	}
	add(_type, _options := "", _text := "", _name := "", _handler := ""){
		types := "Text,Edit,UpDown,Picture,Button,Checkbox,Radio,DropDownList,ComboBox,"
		types .= "ListBox,ListView,TreeView,Link,Hotkey,DateTime,MonthCal,Slider,Progress,"
		types .= "GroupBox,Tab3,StatusBar,ActiveX,Custom"
		;Gui, Add, ControlType [, Options, Text]
	}
	show(_options := ""){
	}
	submit(){}
	hide(){}
	minimize(){}
	maximize(){}
	restore(){}
	gui(args*){
	}
	guicontrol(args*){
	}
	guicontrolget(args*){
	}
}






xscreen_center(width := 0){
	CoordMode, Mouse, Screen
	MouseGetPos, MX, MY
	SysGet, MonitorsCount, MonitorCount
	loop, % MonitorsCount
	{
		SysGet, MonitorVars_, Monitor, %A_Index%
		monitorX := MonitorVars_Left
		MonitorW := MonitorVars_Right - MonitorVars_Left
		MonitorH := MonitorVars_Bottom - MonitorVars_Top
		if (MX <= MonitorVars_Right AND MX >= monitorX){
			width := abs(width)
			return Round(MonitorX + ((monitorW / 2) - (width ? (width / 2) : 0)))
		}
	}
}
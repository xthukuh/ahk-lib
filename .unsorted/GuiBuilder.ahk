;imports
#Include <class_config>
#Include <xtrim>
#Include <xclone>
#Include <xthrow>
#Include <xnum>

;builder
class GuiBuilder extends class_config {
	__config_default := {name: 1, title: "Untitled"}
	__options_default := {toolwindow: 0
		, alwaysontop: 0
		, center: 0
		, autosize: 0
		, minimize: 0
		, maximize: 0
		, restore: 0
		, noactivate : 0
		, na: 0
		, hide: 0
		, x: ""
		, y: ""
		, w: ""
		, h: ""
		, owner: ""
		, modal: 1
		, resize: 0
		, minsize: ""}
	name {
		get {
			return StrLen(name := xtrim(this.config.name)) ? name : (this.config.name := 1)
		}
		set {
			return this.config.name := StrLen(value := xtrim(value)) ? value : 1
		}
	}
	title {
		get {
			return xtrim(this.config.title)
		}
		set {
			return this.config.title := xtrim(value)
		}
	}
	id {
		get {
			if !StrLen(name := xtrim(this.name))
				return
			Gui, %name%: +HWND__gb_hwnd
			return __gb_hwnd
		}
	}
	created {
		get {
			return !!this.config.created
		}
		set {
			return this.config.created := !!value
		}
	}
	showing {
		get {
			return !!this.config.showing
		}
		set {
			return this.config.showing := !!value
		}
	}
	options {
		get {
			options := this.config.options
			if !(isObject(options) && options.Count())
				return this.config.options := xclone(this.__options_default)
			return options
		}
		set {
			return this.config.options := (isObject(value) ? value : xclone(this.__options_default))
		}
	}
	grid {
		get {
			return (isObject(grid := this.config.grid) && grid.__Class == "GuiBuilder_Grid") ? grid : new GuiBuilder_Grid(this)
		}
		set {
			value := (isObject(value) && value.__Class == "GuiBuilder_Grid") ? value : new GuiBuilder_Grid(this)
			return this.config.grid := value
		}
	}
	menu {
		get {}
		set {}
	}
	__New(_name := "main", _title := "Untitled", _options := ""){
		this.name := _name
		this.title := _title
		this.options := _options
	}
	
	add(GuiBuilder_Item := ""){
	}
	
	font(){}
	color(){}
	margin(){}
	options(){}
	menu(){}
	add(){}
}
class GuiBuilder_MenuItem {
	__New(name, options := ""){
		if !StrLen(name := xtrim(name))
			xthrow("Invalid GuiBuilder Menu Item Name")
		this.name := name
	}
	
}
class GuiBuilder_Menu {

}

class GuiBuilder_Grid {
	__New(builder){
		if !(isObject(builder) && builder.__Class == "GuiBuilder")
			xthrow("Invalid GuiBuilder object in GuiBuilder_Grid constructor")
		this.gui_builder := this._builder(builder)
		this.items := []
	}
	_is_builder(builder){
		
		return builder
	}
	builder(){
		return this._builder(this.gui_builder)
	}
	
	font(_name := "", _options := ""){
		name := xtrim(name)
		options := ["Norm"]
		if isObject(_options)
		{
			for key, val in _options
			{
				if !StrLen(val := xtrim(val))
					continue
				key := Format("{:L}", xtrim(key))
				if (key == "name" || key == "font")
				{
					name := val
					continue
				}
				if (key == "size" || key == "s")
				{
					val := xnum(ltrim(val, "s"), -1)
					if val < 0
						continue
					options["size"] := "s" floor(val * 1)
				}
				else if (key == "color" || key == "c")
				{
					if StrLen(val := ltrim(val, "c"))
					{
						if RegExMatch(val, "iO)^#?([0-9a-f]{3,6})$", matches)
						{
							options["color"] := "c" matches[1]
							continue
						}
						names := {black:"000000",silver:"C0C0C0",gray:"808080",white:"FFFFFF",maroon:"800000",red:"FF0000",purple:"800080",fuchsia:"FF00FF",green:"008000",lime:"00FF00",olive:"808000",yellow:"FFFF00",navy:"000080",blue:"0000FF",teal:"008080",aqua:"00FFFF"}
						if names.HasKey(val)
						{
							options["color"] := "c" names[val]
							continue
						}
					}
				}
				else if (key == "weight" || key == "w")
				{
					if StrLen(val := xnum(ltrim(val, "w"), ""))
						options["weight"] := "s" floor(val * 1)
				}
				else if (key == "bold")
				else if (key == "italic")
				else if (key == "strike")
				else if (key == "underline")
				else if (key == "quality")
				else if (key == "")
				{
				}
			}
		}
		
		
		item := {command: "Font", options: "", name: ""}
		
		;{name: "Verdana", size: 8, color: "Default", weight: 0, bold: 0, italic: 0, strike: 0, underline: 0, quality: 0}
		command := "Font"
		command_options := ""
		if isObject(options)
		{
			if options.Count()
			{
				temp := {name: "Verdana", size: 8, color: "Default", weight: 0, bold: 0, italic: 0, strike: 0, underline: 0, quality: 0}
				for key, val in options
					if temp.HasKey(key)
						temp[key] := val
				xoptions := ""
				
			}
		}
		static _default := 
		temp := xclone(_default)
		if isObject(_options)
		{
		}
		option := Format("{:L}", xtrim(_options))
		else if (_default.HasKey())
			temp[key] := 1
		
	}
}

class GuiBuilder_Item extends class_config {
	__New(_type := "", _options := "", _value := "", _default := ""){
		this.config.type := xtrim(_type)
		this.config.options := IsObject(_options) ? _options : {}
		this.config.value := _value
		this.config.default := _default
	}
}
class GuiBuilder_Menu {}

class GuiBuilder_Gui {
	__New(_name){}
	hide(){}
	cancel(){}
	destroy(){}
	show(_options := ""){}
	maximize(){}
	minimize(){}
	restore(){}
	flash(){}
	default(){}
	owndialogs(){}
	move(x := "", y := "", w := "", h := ""){}
	submit(_hide := false){}
}

class GuiBuilder_Item extends class_config {
	static types := "Text,Edit,UpDown,Picture,Button,Checkbox,Radio,DropDownList,ComboBox,ListBox,ListView,TreeView,Link,Hotkey,DateTime,MonthCal,Slider,Progress,GroupBox,Tab3,StatusBar,ActiveX,Custom"
	type {
		get {}
		set {
			if !StrLen(type := Format("{:T}", xtrim(value)))
				return
			types := this.types
			if type not in %types%
				return
			type := Format("{:Ts}", type)
			StringLower, type, type
			StringMid, first, type
			this._config("type", type)
		}
	}
	options {
		get {}
		set {}
	}
	__New(_type, _options := ""){}
}

Gui, Tab, Share Logs
Gui, Add, Tab2, x2 y-1 w460 h490 , Share Logs|Settings
Gui, Add, ListView, x12 y39 w440 h400 , ListView
Gui, Add, Progress, x12 y449 w290 h10 , 25
Gui, Add, Button, x312 y449 w140 h30 , Start
Gui, Tab, Settings
Gui, Add, Text, x12 y39 w100 h20 , Poshmark Site
Gui, Add, Edit, x112 y39 w340 h20 , Edit
Gui, Add, GroupBox, x12 y69 w440 h80 , GUI Settings
Gui, Add, Text, x22 y89 w70 h20 , Font
Gui, Add, Edit, x92 y89 w180 h20 , Edit
Gui, Add, Text, x282 y89 w70 h20 , Font Size
Gui, Add, Edit, x352 y89 w90 h20 , Edit
Gui, Add, CheckBox, x22 y119 w110 h20 , Resizable
Gui, Add, GroupBox, x12 y159 w440 h110 , Account
Gui, Add, Text, x22 y179 w90 h20 , Login Email
Gui, Add, Edit, x112 y179 w330 h20 , Edit
Gui, Add, Text, x22 y209 w90 h20 , Login Password
Gui, Add, Edit, x112 y209 w330 h20 , Edit
Gui, Add, CheckBox, x22 y239 w190 h20 , Login With Google
Gui, Add, Text, x12 y279 w220 h20 , Skip Containing Texts (Comma separated)
Gui, Add, Edit, x12 y299 w440 h40 , Edit
Gui, Add, Text, x12 y349 w440 h20 , Other Usernames To Share (Comma separated) i.e. @user1`, @user2`, @user3
Gui, Add, Edit, x12 y369 w440 h40 , Edit
Gui, Tab, Settings
Gui, Add, Text, x12 y419 w150 h20 , Load More Max No. Of Times
Gui, Add, Edit, x162 y419 w90 h20 , Edit
Gui, Add, Button, x312 y449 w140 h30 , Save
Gui, Add, Button, x212 y449 w90 h30 , Reset
Gui, Tab, Settings
Gui, Add, CheckBox, x142 y119 w110 h20 , Save Log Files
; Generated using SmartGUI Creator for SciTE
Gui, Show, w467 h494, Untitled GUI
return

GuiClose:
ExitApp
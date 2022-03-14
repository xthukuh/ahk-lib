#Include <xhead>

_checked := {}
_func := Func("on_item_func")

/*
gui_menu := new Menu()

file_menu := new Menu()
file_menu.add("Handle Item", "handle_item")
file_menu.add("On Item", "on_item")

gui_menu.add("File", file_menu)
*/

Menu, FileMenu, Add, Handle Item, handle_item

Menu, FileMenu, Add, On Item, on_item
Menu, FileMenu, Add, On Item Func, %_func%, +Right +Break
Menu, FileMenu, Add, Check Radio 1, _check_handler, +Radio
Menu, FileMenu, Add, Check Radio 2, _check_handler, +Radio
Menu, FileMenu, Add, Check 1, _check_handler, -Right
Menu, FileMenu, Add, Check 2, _check_handler
Menu, FileMenu, Add, Check a, _check_handler, +BarBreak
Menu, FileMenu, Add, Check b, _check_handler, -BarBreak
Menu, FileMenu, Add, Check c, _check_handler
Menu, FileMenu, Add, Check d, _check_handler
Menu, FileMenu, Add
Menu, FileMenu, Add, Quit
Menu, FileMenu, Add, Reload

Menu, GuiMenu, Add, File, :FileMenu

Gui, Menu, GuiMenu
Gui, Show, w400 h400 xCenter yCenter, Test Menu

str := "MenuGetHandle"
str .= "`n" (s := "FileMenu") " = " MenuGetHandle(s)
str .= "`n" (s := "GuiMenu") " = " MenuGetHandle(s)
str .= "`n" (s := "Tray") " = " MenuGetHandle(s)
str .= "`n" (s := "Test") " = " MenuGetHandle(s)
Menu, FileMenu, Delete
str .= "`n" (s := "FileMenu") " = " MenuGetHandle(s)
_xmsg(str)
return

Reload:
Reload
return

quit:
GuiEscape:
GuiClose:
ExitApp


#Include <xtest>

_check_handler:
pos := A_ThisMenuItemPos
name := A_ThisMenuItem
menu := A_ThisMenu
if _checked[pos]
	_checked[pos] := 0, change := "UnCheck"
else _checked[pos] := 1, change := "Check"
Menu, %menu%, %change%, %name%
return

handle_item:
_tip("handle_item(" A_ThisMenuItem ", " A_ThisMenuItemPos ", " A_ThisMenu ")")
return

on_item(name := "", pos := "", menu := ""){
	_tip("on_item(" name ", " pos ", " menu ")")
	return true
}

on_item_func(name := "", pos := "", menu := ""){
	_tip("on_item_func(" name ", " pos ", " menu ")")
	return false
}

_tip(msg){
	global _tip_clear
	ToolTip, % msg
	
	_tip_clear := 0
	SetTimer, _tip_clear, 2000
	Hotkey, LButton, _tip_clear, On
	return
	
	_tip_clear:
	if _tip_clear
		return
	_tip_clear := 1
	SetTimer, _tip_clear, Off
	Hotkey, LButton, _tip_clear, Off
	ToolTip
	return
}

#Include <class_config>
#Include <xthrow>
#Include <xtrim>

class MenuItem extends class_config {
	menu {
		get {
			return xtrim(this.config.menu)
		}
		set {
			return this.config.menu := xtrim(value)
		}
	}
	name {
		get {
			return xtrim(this.config.name)
		}
		set {
			return this.config.name := xtrim(value)
		}
	}
	handler {
		get {
			return xtrim(this.config.handler, 1)
		}
		set {
			return this.config.handler := xtrim(value, 1)
		}
	}
	options {
		get {
			return xtrim(this.config.options, 1)
		}
		set {
			buffer := ""
			if ((value := xtrim(value)) != "")
			{
				loop, parse, value, %A_Space%
				{
					if ((item := xtrim(A_LoopField)) == "")
						continue
					if RegExMatch(item, "i)^(p\d+|([\+-]?(radio|right|break|barbreak)))$")
						buffer .= (buffer == "" ? "" : " ") item
				}
			}
			return this.config.options := buffer
		}
	}
	items {
		get {
			return IsObject(items := this.config.items) ? items : (this.config.items := [])
		}
		set {
			return this.config.items := IsObject(value) ? value : []
		}
	}
	__New(_name, _handler := "", _options := "", _menu := ""){
		this.name := _name
		this.handler := _handler
		this.options := _options
		this.menu := _menu
		this.config.items := []
	}
	add(_name := "", _handler := "", _options := ""){
		_name := xtrim(_name)
		if (_name == "")
		{
			this.items.Insert("div")
			return
		}
		if (isObject(_handler) && _handler.__Class == this.__Class)
		{
			hname := _handler.name
			hitems := _handler.items
			Menu, %name%, Add, %hname%, :%hname%
		}
		if (item == "" || isObject(item) && item.__Class == this.__Class)
			this.items.Insert(item)
		return this
	}
	create(_menu := ""){
		if !StrLen(name := xtrim(this.name))
			return
		;_menu := StrLen(_menu := xtrim(_menu)) ? _menu : name
		items := this.items
		options := this.options
		if items.Count()
		{
			for i, item in items
			{
				if (isObject(item) && item.__Class == this.__Class)
				{
					item_menu := item.create(name)
					
						Menu, %items_menu%, Add, %item_name%, %item_handler%, %item_options%
					Menu, %menu_name%, Add, %item_name%, %item_handler%, %item_options%
				}
				else if (item == "")
					Menu, %menu_name%, Add
			}
			Menu, %name%, Add, %name%, :%menu_name%
		}
		Menu, FileMenu, Add, On Item, on_item
	}
	remove(){
		name := this.name
		
		if MenuGetHandle(name)
			Menu, %name%, Delete
	}
}
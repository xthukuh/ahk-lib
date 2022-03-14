/*
	Menu Builder
	By Martin Thuku (2021-07-16 23:46:27)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

class xmenu_builder extends xclass
{
	;new instance
	__New(name, title := "")
	{
		;properties
		this._title := (title := xtrim(title))
		
		;xclass - set instance name < this._name
		name := this.new_instance(name)
	}

	;get handle
	handle()
	{
		if !(name := this.name())
			return
		return MenuGetHandle(name)
	}

	;item count
	item_count()
	{
		return DllCall("GetMenuItemCount", "ptr", this.handle())
	}

	;item id
	item_id(index := 0)
	{
		index := index >= 0 && index < this.item_count() ? index : 0
		return DllCall("GetMenuItemID", "ptr", this.handle(), "int", index)
	}

	;add
	add(name, title, handler := "", options := "")
	{
		;Menu, MenuName, Add , MenuItemName, LabelOrSubmenu, Options
	}
}
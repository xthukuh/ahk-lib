;includes

;xgui helper - listview
class xgui_helper_lv
{
	;new instance
	__New(gui_helper, name)
	{
		this._gui_helper := gui_helper
		this._name := name
	}

	;get gui helper
	gui(throwable := true)
	{
		if xgui_helper.is_instance(gui_helper := this._gui_helper)
			return gui_helper
		if throwable
			throw "Invalid " this.__class " gui helper instance."
	}

	;get listview control
	lv()
	{
		_ctrl := this.gui().ctrl(this._name)
	}

	;todo
}
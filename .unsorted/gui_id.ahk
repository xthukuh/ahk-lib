gui_id(name := ""){
	if !(name := xtrim(name))
		return
	Gui, %name%: +HWND_gui_hwnd
	return _gui_hwnd
}

#Include <xtrim>
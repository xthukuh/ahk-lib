/*
	Edit Scroll Bottom
	By Martin Thuku (2021-07-02 19:48:58)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

xedit_scroll_bottom(name, window_hwnd){
	static classnn_cache

	;get edit classnn
	if !isObject(classnn_cache)
		classnn_cache := Object()
	if !classnn_cache.HasKey(name)
	{
		GuiControlGet, edit_hwnd, Hwnd, %name%
		classnn_cache[name] := edit_classnn := xcontrol_classnn(edit_hwnd, window_hwnd)
	}
	else edit_classnn := classnn_cache[name]
	
	;Scroll to bottom
	;0x115 - WM_VSCROLL
	;7 - SB_BOTTOM
	SendMessage, 0x115, 7, 0, %edit_classnn%, ahk_id %window_hwnd%
}

;requires
#Include *i %A_LineFile%\..\xcontrol_classnn.ahk
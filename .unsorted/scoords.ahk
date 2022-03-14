;creates a click-and-drag selection box to specify an area
GetSelectionCoords(ByRef x_start, ByRef x_end, ByRef y_start, ByRef y_end){
	;Mask Screen
	Gui, _mask_screen_: Color, FFFFFF
	Gui, _mask_screen_: +LastFound
	_mask_screen_hwnd := WinExist()
	WinSet, Transparent, 50
	Gui, _mask_screen_: -Caption 
	Gui, _mask_screen_: +AlwaysOnTop
	Gui, _mask_screen_: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%, "mask screen"

	;Drag Mouse
	CoordMode, Mouse, Screen
	CoordMode, Tooltip, Screen
	hdc_frame_m := DllCall("GetDC", "uint", _mask_screen_hwnd)
	
	;mouse drag draw box
	KeyWait, LButton, D
	MouseGetPos, scan_x_start, scan_y_start 
	Loop
	{
		Sleep, 10   
		KeyIsDown := GetKeyState("LButton")
		if KeyIsDown
		{
			MouseGetPos, scan_x, scan_y 
			DllCall("gdi32.dll\Rectangle", "uint", hdc_frame_m, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenWidth)
			DllCall("gdi32.dll\Rectangle", "uint", hdc_frame_m, "int", scan_x_start, "int", scan_y_start, "int", scan_x, "int", scan_y)
		}
		else break
	}
	MouseGetPos, scan_x_end, scan_y_end
	
	;close mask screen
	Gui, _mask_screen_: Destroy
	
	;set selection box values
	if (scan_x_start < scan_x_end)
	{
		x_start := scan_x_start
		x_end := scan_x_end
	}
	else {
		x_start := scan_x_end
		x_end := scan_x_start
	}
	if (scan_y_start < scan_y_end)
	{
		y_start := scan_y_start
		y_end := scan_y_end
	}
	else {
		y_start := scan_y_end
		y_end := scan_y_start
	}
}
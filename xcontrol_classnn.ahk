/*
	Get Control ClassNN
	By Martin Thuku (2021-07-02 19:47:06)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

xcontrol_classnn(control_hwnd, window_hwnd){
	result =
	detect_hidden := A_DetectHiddenWindows
	DetectHiddenWindows, On
	WinGet, classnn_list, ControlList, ahk_id %window_hwnd%
	Loop, Parse, classnn_list, `n
	{
		ControlGet, hwnd, hwnd,, %A_LoopField%, ahk_id %window_hwnd%
		if (hwnd = control_hwnd)
		{
			result := A_LoopField
			break
		}
	}
	DetectHiddenWindows, %detect_hidden%
	return result
}
xprog_marquee(_control := "", _gui := 1){
	static WM_USER := 0x00000400, PBM_SETMARQUEE := WM_USER + 10, PBS_MARQUEE := 0x00000008, PBS_SMOOTH := 0x00000001
	if ((_control := xtrim(_control)) == "")
		return
	_gui := (_gui := trim(_gui, " :`t`r`n")) != "" ? _gui ":" : ""
	Gui, %_gui% Default ;default gui
	GuiControlGet, _hwnd, HWND, %_control%
	GuiControl, -0x00000001, %_control% ;PBS_SMOOTH := 0x00000001
	GuiControl, +0x00000008, %_control% ;PBS_MARQUEE := 0x00000008
	GuiControl,, %_control%, 50 ;set value
	DllCall("User32.dll\SendMessage", "Ptr", _hwnd, "Int", PBM_SETMARQUEE, "Ptr", 1, "Ptr", 50)
}

#Include <xtrim>
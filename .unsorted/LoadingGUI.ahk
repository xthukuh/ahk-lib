#SingleInstance, force
#Persistent
#NoEnv

loading := LoadingGUI()
loading.show("", "x200 y200")
sleep, 5000
loading.progress(20)
sleep, 2000
loading.progress(50)
sleep, 2000
loading.progress(60)
sleep, 2000
loading.progress(100)
sleep, 2000
loading.marquee()
sleep, 5000
loading.destroy()
MsgBox Done!

LoadingGUI(text := "Please wait..."){
	global __lg_prog, __lg_prog_hwnd, __lg_text, __lg_text_bak
	__lg_text_bak := text
	PBS_MARQUEE := 0x00000008
	PBS_SMOOTH := 0x00000001
	Gui, __loading_gui: +LastFound
	__loading_gui_hwnd := WinExist()
	Gui, __loading_gui: -Border +ToolWindow
	Gui, __loading_gui: Add, Text, x12 y9 w200 h20 v__lg_text, % text
	Gui, __loading_gui: Add, Progress, x12 y39 w200 h10 v__lg_prog hwnd__lg_prog_hwnd -Smooth +Range0-100, 0
	
	self := {}
	self.hwnd := __loading_gui_hwnd
	self.prog_hwnd := __lg_prog_hwnd
	self.show := Func("__lg_show")
	self.progress := Func("__lg_progress")
	self.marquee := Func("__lg_marquee")
	self.destroy := Func("__lg_destroy")
	return self
}

__lg_show(parent_gui := "", options := ""){
	global __loading_gui, __lg_prog_hwnd
	;WM_USER := 0x00000400
	;PBM_SETMARQUEE := WM_USER + 10
	options := RegExReplace(options, "w[0-9]+")
	options := RegExReplace(options, "h[0-9]+")
	options := RegExReplace(options, "\s+", " ")
	options := RegExReplace(options, "^\s*|\s*$")
	options .= (options == "" ? "" : " ") "w226 h66"
	parent_gui := RegExReplace(parent_gui, "^\s*|\s*$")
	if parent_gui !=
		Gui, __loading_gui: +Owner%parent_gui%
	Gui, __loading_gui: Show, %options%, Loading
	;DllCall("User32.dll\SendMessage", "Ptr", __lg_prog_hwnd, "Int", PBM_SETMARQUEE, "Ptr", 1, "Ptr", 50)
}

__lg_progress(percentage := 0){
	global __lg_prog, __lg_text, __lg_text_bak
	PBS_MARQUEE := 0x00000008
	percentage := percentage * 1
	percentage := percentage < 0 ? 0 : (percentage > 100 ? 100 : percentage)
	Gui, __loading_gui: Default
	GuiControl, -0x8, __lg_prog
	GuiControl,, __lg_prog, % percentage
	GuiControl,, __lg_text, %__lg_text_bak% (%percentage%`%)
}

__lg_marquee(){
	global __lg_prog, __lg_prog_hwnd
	;PBS_MARQUEE := 0x00000008
	;WM_USER := 0x00000400
	;PBM_SETMARQUEE := WM_USER + 10
	Gui, __loading_gui: Default
	GuiControl,, __lg_prog, 10
	GuiControl, +0x8, __lg_prog
	;DllCall("User32.dll\SendMessage", "Ptr", __lg_prog_hwnd, "Int", PBM_SETMARQUEE, "Ptr", 1, "Ptr", 50)
}

__lg_destroy(){
	Gui, __loading_gui: Destroy
}



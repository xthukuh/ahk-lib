ImageSize(file, byref width := "", byref height := ""){
	Random, ran, 1000, 900000
	g := "gui" ran
	gui, %g%: Add, Picture, hwnd_pic0000000, % file
	ControlGetPos,,, width, height,, ahk_id %_pic0000000%
	gui, %g%: Destroy
}
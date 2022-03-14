xhwnd(){
	pid := xpid()
	if pid is not integer
		return
	if !(pid > 0)
		return
	_temp := A_DetectHiddenWindows
	DetectHiddenWindows, On
	hwnd := WinExist("ahk_pid " pid)
	DetectHiddenWindows, %_temp%
	return hwnd
}

#Include <xpid>
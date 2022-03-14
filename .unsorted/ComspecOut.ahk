ComspecOut(cmd){
	cmd := RegExReplace(cmd, "^\s*|\s*$")
	if cmd =
		return
	bak := A_DetectHiddenWindows
	DetectHiddenWindows, On
	Run, "%ComSpec%" /k,, Hide, pid
	while !(hConsole :=  WinExist("ahk_pid " pid))
		sleep, 10
	DllCall("AttachConsole", "UInt", pid)
	DetectHiddenWindows, %bak%
	shell := ComObjCreate("wscript.shell")
	exec := (shell.exec(comspec " /c " cmd))
	while !exec.Status
		sleep, 100
	stdout := exec.StdOut.ReadAll()
	DllCall("FreeConsole")
	Process, Exist, %pid%
	if (ErrorLevel == pid)
		Process, Close, %pid%
	return RegExReplace(stdout, "^\s*|\s*$")
}
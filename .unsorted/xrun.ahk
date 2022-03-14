;xrun(cmd, true, "Hide", false, false)
xrun(cmd, _comspec := true, _hide := "Hide", _wait := false, _admin := false){
	if _comspec
		target = %ComSpec% /c "%cmd%"
	else target = %cmd%
	if _admin
	{
		if _wait
			RunWait, *RunAs %target%,, %_hide%
		else Run, *RunAs %target%,, %_hide%
	}
	else {
		if _wait
			RunWait, %target%,, %_hide%
		else Run, %target%,, %_hide%
	}
}

;run ahk script
xrun_ahk(path := "", _wait := false, _args*){
	path := trim(path, " `t`r`n")
	if path =
		path := A_ScriptFullPath
	if !RegExMatch(path, "^""(.*)""$")
		path = "%path%"
	cmd := A_IsCompiled ? path : """" A_AhkPath """ " path
	loop, % _args.Length()
		cmd .= " " _args[A_Index]
	xrun(cmd,,, _wait)
}

/*
cl= /c start "%scriptName%" cd /d "%fPath%\"
	DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs"
	, str, "cmd.exe", str, cl, str, """", int, 1)
*/
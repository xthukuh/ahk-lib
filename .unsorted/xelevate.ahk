xelevate(args := ""){
	if A_IsAdmin
		return true
	if A_IsCompiled
		cmd = "%A_ScriptFullPath%" %args%
	else cmd = "%A_AhkPath%" "%A_ScriptFullPath%" %args%
	cmd := rtrim(cmd, " `t`r`n")
	Run *RunAs %cmd%
	ExitApp
}
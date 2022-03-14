xpid(program := ""){
	global __xpid_filter_program
	if StrLen(program := trim(program, " `t`r`n"))
	{
		__xpid_filter_program := program
		items := get_processes(Func("__xpid_filter_program"))
		if (isObject(items) && items.Count())
			return items[1].processId
	}
	else return DllCall("GetCurrentProcessId")
}

__xpid_filter_program(Win32_Process){
	global __xpid_filter_program
	if !StrLen(program := trim(__xpid_filter_program, " `t`r`n"))
		return
	if program is integer
	{
		if (Win32_Process.processId == program)
			return -1
		if (Win32_Process.Handle == program)
			return -1
	}
	else {
		if InStr(Win32_Process.Name, program, false)
			return -1
		if InStr(Win32_Process.CommandLine, program, false)
			return -1
	}
}

#Include <xprocess>


;http://msdn.microsoft.com/en-us/library/aa394372.aspx
xprocess(value){
	valid := true
	if isObject(value)
	{
		if !strlen(name := trim(value.Name, " `t`r`n"))
			valid := false
		pid := floor(value.ProcessId * 1)
		WinGet, hwnd, ID, ahk_pid %pid%
		;hwnd := pid ? WinExist("ahk_pid " pid) : ""
		exe := InStr(name, ".exe") ? name : ""
		WinGetTitle, title, ahk_pid %pid%
		title := trim(title, " `t`r`n")
	}
	if !valid
	{
		ErrorLevel := "Value is not a valid Win32_Process Object"
		return
	}
	temp := Object()
	temp._exe := exe
	temp._pid := pid
	temp._hwnd := hwnd
	temp._title := title
	temp.CreationClassName := value.CreationClassName
	temp.Caption := caption
	temp.CommandLine := value.CommandLine
	temp.CreationDate := value.CreationDate
	temp.CSCreationClassName := value.CSCreationClassName
	temp.CSName := value.CSName
	temp.Description := value.Description
	temp.ExecutablePath := value.ExecutablePath
	temp.ExecutionState := value.ExecutionState
	temp.Handle := hwnd
	temp.HandleCount := value.HandleCount
	temp.InstallDate := value.InstallDate
	temp.KernelModeTime := value.KernelModeTime
	temp.MaximumWorkingSetSize := value.MaximumWorkingSetSize
	temp.MinimumWorkingSetSize := value.MinimumWorkingSetSize
	temp.Name := name
	temp.OSCreationClassName := value.OSCreationClassName
	temp.OSName := value.OSName
	temp.OtherOperationCount := value.OtherOperationCount
	temp.OtherTransferCount := value.OtherTransferCount
	temp.PageFaults := value.PageFaults
	temp.PageFileUsage := value.PageFileUsage
	temp.ParentProcessId := value.ParentProcessId
	temp.PeakPageFileUsage := value.PeakPageFileUsage
	temp.PeakVirtualSize := value.PeakVirtualSize
	temp.PeakWorkingSetSize := value.PeakWorkingSetSize
	temp.Priority := value.Priority
	temp.PrivatePageCount := value.PrivatePageCount
	temp.ProcessId := pid
	temp.QuotaNonPagedPoolUsage := value.QuotaNonPagedPoolUsage
	temp.QuotaPagedPoolUsage := value.QuotaPagedPoolUsage
	temp.QuotaPeakNonPagedPoolUsage := value.QuotaPeakNonPagedPoolUsage
	temp.QuotaPeakPagedPoolUsage := value.QuotaPeakPagedPoolUsage
	temp.ReadOperationCount := value.ReadOperationCount
	temp.ReadTransferCount := value.ReadTransferCount
	temp.SessionId := value.SessionId
	temp.Status := value.Status
	temp.TerminationDate := value.TerminationDate
	temp.ThreadCount := value.ThreadCount
	temp.UserModeTime := value.UserModeTime
	temp.VirtualSize := value.VirtualSize
	temp.WindowsVersion := value.WindowsVersion
	temp.WorkingSetSize := value.WorkingSetSize
	temp.WriteOperationCount := value.WriteOperationCount
	temp.WriteTransferCount := value.WriteTransferCount
	return temp
}

get_processes(_filter_func := ""){
	items := []
	for proc in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
	{
		if IsFunc(_filter_func)
		{
			_value := %_filter_func%(proc)
			if !_value
				continue
			if (_value == -1)
			{
				items.Insert(proc)
				break
			}
		}
		items.Insert(proc)
	}
	return items
}


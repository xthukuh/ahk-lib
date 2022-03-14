;xcopy
xcopy(source, destination, _overwrite := true, _move := false){
	if !(destination := xpath(destination, A_WorkingDir))
		return xerror("Invalid destination path """ destination """")
	if !(source := xpath(source, A_WorkingDir))
		return xerror("Invalid source path """ source """")
	if !(exist := FileExist(source))
		return xerror("Source path does not exist """ source """")
	if instr(exist, "D")
	{
		if !(dest := xdir(destination))
			return xerror("Error creating destination folder """ destination """")
		if _move
		{
			if _overwrite
				FileMoveDir, %source%, %dest%, 2
			else
				FileMoveDir, %source%, %dest%, 0
			if ErrorLevel
				return xerror("Unable to move """ source """ to """ dest """")
			return true
		}
		FileCopyDir, %source%, %dest%, %_overwrite%
		if ErrorLevel
			return xerror("Unable to copy """ source """ to """ dest """")
		return true
	}
	if !(dest := xfile(destination))
		return xerror("Error preparing destination path """ destination """")
	if _move
	{
		FileMove, %source%, %dest%, %_overwrite%
		if ErrorLevel
			return xerror("Unable to move """ source """ to """ dest """")
		return true
	}
	FileCopy, %source%, %dest%, %_overwrite%
	if ErrorLevel
		return xerror("Unable to copy """ source """ to """ dest """")
	return true
}

#Include <xfiles>
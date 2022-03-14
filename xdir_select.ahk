;select folder dialog
xdir_select(prompt := "", opts := "1", starting_folder := ""){
	FileSelectFolder, out, % starting_folder, % opts, % prompt
	if (!ErrorLevel && (out := Trim(out, " `r`n`t")))
		return out
}
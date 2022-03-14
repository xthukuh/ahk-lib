ClipboardData(){
	VarCap := VarSetCapacity(Source, 0)
	Source := ClipboardAll
	VarCap := VarSetCapacity(Source)
	Content := ""
	Loop, % VarCap
		Content .= Chr(NumGet(Source, A_Index-1, "UChar"))
	VarCap := VarSetCapacity(Content)
	return Content
}
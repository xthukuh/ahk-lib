/*
	File Select Helper
	By Martin Thuku (2021-05-19 23:01:34)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io

	file select dialog filter
		- Audio (*.wav; *.mp2; *.mp3)
	xfile_select("Select multiple", "M", ...)
*/

;file select
xfile_select(prompt := "", opts := "1", filter := "All Files (*.*)", root_dir := ""){
	FileSelectFile, out, % opts, % root_dir, % prompt, % filter
	if (!ErrorLevel && (out := xtrim(out)))
		return out
}

;save as dialog
xfile_select_save(prompt := "", ext := "", filter := "", root_dir := ""){
	if ((ext := xtrim(RegExReplace(ext, "i)[^\w\d]", ""))) && filter == "")
		filter := "All Files (*." ext ")"
	if filter =
		filter := "All Files (*.*)"
	if (path := xfile_select(prompt, "S16", filter, root_dir))
		path := xpath(path, _error, ext)
	return path
}

;requires
#Include *i %A_LineFile%\..\xtrim.ahk
#Include *i %A_LineFile%\..\xpath.ahk
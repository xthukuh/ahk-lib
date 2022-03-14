/*
	File Append Helper
	By Martin Thuku (2021-05-31 00:16:44)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/
xfile_append(content := "", filename := "", encoding := ""){
	SplitPath, filename, _basename, _dir
	IfNotExist
	;FileAppend , Text, Filename, Encoding
	;..
}
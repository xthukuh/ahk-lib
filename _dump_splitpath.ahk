;dump string - split path
_dump_splitpath(path){
	SplitPath, path, _basename, _dir, _ext, _name, _drive
	s := "SplitPath: " path "`n"
	s .= "_basename: " _basename "`n"
	s .= "_dir: " _dir "`n"
	s .= "_ext: " _ext "`n"
	s .= "_name: " _name "`n"
	s .= "_drive: " _drive "`n"
	return s
}
;xfiles
is_dir(ByRef path){
	return (path := xtrim(path)) && (s := FileExist(path)) && InStr(s, "D")
}
xdir(path, mkdir := true){
	if !is_dir(path)
	{
		SplitPath, path,, dir,, name
		if !xtrim(name)
			return xerror("Invalid dir path: " path)
		path := dir "\" name
		if mkdir
		{
			FileCreateDir, % path
			if ErrorLevel
				return xerror("Unable to create directory: " path)
		}
	}
	return path
}
is_file(ByRef path){
	return (path := xtrim(path)) && (s := FileExist(path)) && !InStr(s, "D")
}
xfile(path, mkdir := true){
	if !is_file(path)
	{
		SplitPath, path, fname, dir, ext, name
		if !xtrim(name)
			return xerror("Invalid file path: " path)
		if mkdir
			dir := xdir(dir)
	}
	return path
}
file_delete(path){
	if is_file(path)
	{
		FileDelete, % path
		if ErrorLevel
			return xerror("Unable to delete file """ path """", false)
	}
	return true
}
dir_delete(path, recurse := true){
	if is_dir(path)
	{
		FileRemoveDir, %path%, %recurse%
		if ErrorLevel
			return xerror("Unable to delete folder """ path """", false)
	}
	return true
}
xdelete(path, recurse := true){
	if (exist := FileExist(path))
		return InStr(exist, "D") ? dir_delete(path) : file_delete(path)
	return true
}

#Include <xtrim>
#Include <xerror>
#Include <is_fname>
#Include <xpath>
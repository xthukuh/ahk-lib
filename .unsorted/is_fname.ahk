is_fname(name){
	return (name := xtrim(name)) && !RegExMatch(name, "[\\/:\*\?""\<\>\|]")
}
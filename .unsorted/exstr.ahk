exstr(ex, message := true, what := true, extra := false, file := false, line := false){
	error := ""
	if isObject(ex)
	{
		if (message && ex.HasKey("message"))
			xbuffer(error, ex.message)
		if (what && ex.HasKey("what"))
			xbuffer(error, ex.what)
		if (extra && ex.HasKey("extra"))
			xbuffer(error, ex.extra, "`n")
		if (file && ex.HasKey("file"))
			xbuffer(error, "File: " xtrim(ex.file), "`n", false)
		if (line && ex.HasKey("line"))
			xbuffer(error, "Line: " xtrim(ex.file), " ", false)
	}
	else error := xtrim(error)
	return error
}

#Include <xtrim>
#Include <xbuffer>
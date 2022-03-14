;join helper
xjoin(glue := "`n", items*){
	buffer := ""
	has_index := InStr(glue, "{index}")
	loop, % items.Length()
	{
		sep := has_index ? StrReplace(glue, "{index}", A_Index) : glue
		buffer .= (buffer != "" ? sep : (has_index ? LTrim(sep, " `t`r`n") : "")) items[A_Index]
	}
	return buffer
}
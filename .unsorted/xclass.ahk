xclass(obj){
	return isObject(obj) ? trim(obj.__Class, " `t`r`n") : ""
}
;trim helper
xtrim(var, _object := false){
	return IsObject(var) ? (_object ? var : "") : Trim(var, " `t`r`n") ;RegExReplace(var, "^\s*|\s*$")
}
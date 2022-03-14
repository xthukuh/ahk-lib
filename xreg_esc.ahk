;escape regex string
xreg_esc(str){
	return RegExReplace(str, "[\.\*\+\?\^\$\{\}\(\)\|\[\]\\]", "\$0")
	;return "\E\Q" RegExReplace(str, "\\E", "\E\\E\Q") "\E"
}
;escape command line param
xcli_esc(param, _quotes := 0){
	s := RegExReplace(param, "(\\*)""", "$1$1\""")
	return _quotes ? """" s """" : s
}
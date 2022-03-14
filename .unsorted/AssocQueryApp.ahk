;get application path associated with ext
AssocQueryApp(ext){
	RegRead, type, HKCR, .%ext%
	RegRead, act , HKCR, %type%\shell
	If ErrorLevel
		act = open
	RegRead, cmd , HKCR, %type%\shell\%act%\command
	pathRegEx = C:\\[^"/:\*\?<>\|]+
	RegExMatch(cmd, pathRegEx, path)
	Return, path
}
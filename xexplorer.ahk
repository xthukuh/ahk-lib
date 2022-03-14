xexplorer(path := ""){
	cmd := "explorer"
	IfExist, % path
		cmd .= " /select, """ path """"
	Run, %ComSpec% /c "%cmd%",, Hide
}
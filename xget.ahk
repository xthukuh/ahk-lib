;fetch request
xget(url, ByRef _error := ""){
	try {
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.open("GET", url)
		whr.send()
		return whr.responseText
	}
	catch e
	{
		err =
		err .= Trim(e.What, " .`n`r`t")
		err .= ". " Trim(e.Message, " .`n`r`t")
		err .= ". " Trim(e.Extra, " .`n`r`t")
		_error := Trim(err, " .`n`r`t")
	}
}
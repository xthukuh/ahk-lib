;https://autohotkey.com/board/topic/114045-functions-get-public-and-local-ip-addresses/
GetAdaptorIP(name){
    wmi := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
    items := wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapter WHERE NetConnectionID = '" name "'")._NewEnum, items[item]
    items := wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE InterfaceIndex = '" item.InterfaceIndex "'")._NewEnum, items[item]
    ip := item.IPAddress[0]
	return isIP(ip) ? ip : ""
}
GetAdapters(){
	adapters := Object()
	wmi := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
	items := wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapter")._NewEnum, items[item]
	while (items[item])
	{
		name := item.NetConnectionID
		index := item.InterfaceIndex
		xitems := wmi.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE InterfaceIndex = '" index "'")._NewEnum, xitems[xitem]
		ip := xitem.IPAddress[0]
		if (name && isIP(ip))
			adapters[name] := ip
	}
	return adapters
}

;https://www.ipify.org/
GetRemoteIP(alert_error := true){
	request := new Request("https://api.ipify.org")
	if (response := request.send())
	{
		ip := request.xtrim(response.text)
		return isIP(ip) ? ip : ""
	}
	else if alert_error
		TrayTip, GetRemoteIP, %ErrorLevel%, 2, 18
	return ""
}

;http://www.computoredge.com/AutoHotkey/Downloads/IPFind.ahk
GetRemoteIPLocation(ip, alert_error := true){
	request := new Request("https://whatismyipaddress.com/ip/" . ip)
	request.timeouts := true
	if (response := request.send())
	{
		RegExMatch(response.text, "Continent(.*)Latitude", Location)
		Location1 := RegExReplace(Location1,"<.+?>")
		str := ""
		loop, parse, Location1, `n
			str .= (str == "" ? "" : "`n") RegExReplace(RegExReplace(A_LoopField, "^\s*|\s*$"), "^:")
		return RegExReplace(str, "^\s*|\s*$")
	}
	else if alert_error
		TrayTip, GetRemoteIPLocation, %ErrorLevel%, 2, 18
	return ""
}
isIP(str){
	if (strlen(ltrim(rtrim(str))) <= 15 && StrSplit(str, ".").Count() == 4)
		return true
	return false
}
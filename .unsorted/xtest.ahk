test_complete:
MsgBox Tests complete!
ExitApp

_xmsg(str, _title := "", _confirm := true, _exitapp := true){
	if _msg(str, _title, _confirm)
	{
		if (!_confirm && _exitapp)
			ExitApp
		return true
	}
	if _exitapp
		ExitApp
	return false
}

_msg(_msg, _title := "", _confirm := false){
	global _msg_alwaysontop
	static atop := 262144
	if StrLen(msg := trim(_msg, " `t`r`n"))
	{
		if StrLen(title := trim(_title, " `t`r`n"))
			title := " - " title
		if _confirm
		{
			n := (_msg_alwaysontop ? atop : 0) + 4
			title := "Continue Test?" title
			MsgBox, % n, % title, % msg
			IfMsgBox, Yes
				return true
		}
		else {
			n := _msg_alwaysontop ? atop : 0
			title := "Test" title
			MsgBox, % n, % title, % msg
			IfMsgBox, Ok
				return true
		}
	}
}

_msgx(str, _title := ""){
	if _msg(str, _title)
		ExitApp
}
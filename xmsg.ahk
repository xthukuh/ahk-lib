xmsg(msg, _exit := 0, title := "Test"){
	msg := RTrim(msg, " `n`t")
	msg =
	( LTRIM
	-----------------------------------------------------
	%msg%
	-----------------------------------------------------
	)
	if _exit
	{
		MsgBox, 0, %title%, % msg
		ExitApp
		return
	}
	msg .= "`nContinue?"
	MsgBox, 4, %title%, % msg
	IfMsgBox, No
		ExitApp
	return
}
;xalerts
xmsg(message, options := ""){
	return xalert(message, options)
}
xinfo(message, options := ""){
	_options := {icon: 64, help: true}
	return xalert(message, oreplace(_options, options))
}
xwarn(message, options := ""){
	_options := {buttons: 1, icon: 48}
	return xalert(message, oreplace(_options, options))
}
xdanger(message, options := ""){
	_options := {buttons: 2, icon: 16, modal: 262144}
	return xalert(message, oreplace(_options, options))
}
xconfirm(message, options := ""){
	_options := {buttons: 4, icon: 16, modal: 262144}
	return xalert(message, oreplace(_options, options))
}
xalert(message, options := ""){
	if !(message := xtrim(message))
		return
	options := xalert_options(options)
	title := xtrim(options.title)
	opts := 0
	if xin(num := options.buttons, [0, 1, 2, 3, 4, 5, 6])
		opts += num
	if xin(num := options.icon, [0, 16, 32, 48, 64])
		opts += num
	if xin(num := options.default, [0, 256, 768])
		opts += num
	if xin(num := options.modal, [0, 4096, 8192, 262144, 131072])
		opts += num
	if xin(num := options.align, [0, 524288, 1048576])
		opts += num
	if (options.help)
		opts += 16384
	timeout := xtrim(options.timeout)
	timeout := is_int(timeout) ? timeout : ""
	if ((owner := xtrim(options.owner)) && gui_id(owner))
		Gui, %owner%: +OwnDialogs
	MsgBox, % opts, %title%, %message%, %timeout%
	Gui, +OwnDialogs
	IfMsgBox, OK
		return 1
	IfMsgBox, Yes
		return 1
	IfMsgBox, Retry
		return 1
	IfMsgBox, TryAgain
		return 2
	IfMsgBox, Continue
		return 1
	IfMsgBox, No
		return 0
	IfMsgBox, Abort
		return 0
	return
}
xalert_options(options){
	_options := Object()
	_options.title := A_ScriptName
	_options.owner := "" ;owner gui
	_options.buttons := 0 ;0=OK, 1=OK/Cancel, 2=Abort/Retry/Ignore, 3=Yes/No/Cancel, 4=Yes/No, 5=Retry/Cancel, 6=Cancel/Try Again/Continue
	_options.icon := 0 ;0=None, 16=Stop/Error, 32=Question, 48=Exclamation, 64=Info
	_options.default := 0 ;0=None, 256=2nd btn, 768=3rd btn (with help)
	_options.modal := 0 ;0=None, 4096=System, 8192=Task, 262144=AlwaysOnTop, 131072=Default Desktop
	_options.align := 0 ;0=Left, 524288=Right, 1048576=RTL
	_options.help := false ;help
	_options.timeout := 0 ;timeout
	return oreplace(_options, options)
}

#Include <xtrim>
#Include <gui_id>
#Include <oreplace>
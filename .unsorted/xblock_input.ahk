;block input
xblock_input(_block := true, _omit := "Default", _omit_windows := "Default"){
	static cache := Object(), tmode := "", handler := "__xblock_input_handler"
	if cache.Count()
	{
		for key, val in cache
			Hotkey, %hkey%, %handler%, Off
	}
	Hotkey, If
	cache := Object()
	tmode := ""
	_xmsg("_block: " _block)
	if !_block
		return true
	_omit := trim(_omit, " `t`r`n")
	if (_omit != "" && InStr(_omit, "default"))
		_omit := RegExReplace(_omit, "i)default", "Ctrl,Shift,Alt,Win,LButton,MButton,RButton,WheelUp,WheelDown,WheelLeft,WheelRight")
	_omit_windows := trim(_omit_windows, " `t`r`n")
	if (_omit_windows != "" && InStr(_omit_windows, "default"))
		_omit_windows := RegExReplace(_omit_windows, "i)default", "AutoHotkey,Notepad,ahk_exe cmd.exe,ahk_exe PowerShell.exe")
	
	keys := StrSplit("0123456789abcdefghijklmnopqrstuvwxyz``~!@#$%^&*()_-+={}[]|\:;""'<>,.?/")
	_keys := "F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12"
	_keys .= ",NumLock,Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9"
	_keys .= ",NumpadAdd,NumpadClear,NumpadDel,NumpadDiv,NumpadDot,NumpadDown,NumpadEnd,NumpadEnter,NumpadHome"
	_keys .= ",NumpadIns,NumpadLeft,NumpadMult,NumpadPgdn,NumpadPgup,NumpadRight,NumpadSub,NumpadUp"
	_keys .= ",Esc,Insert,PrintScreen,Delete,Home,End,PGUP,PGDN,BackSpace,CapsLock,Enter,Space,Left,Up,Down,Right"
	_keys .= ",LButton,MButton,RButton,WheelUp,WheelDown,WheelLeft,WheelRight"
	keys.push(StrSplit(_keys, ",")*)
	_keys =
	
	_mode := 0
	if _omit !=
	{
		if RegExMatch(_omit, "iO)^/(.+)/$", matches)
		{
			_omit := xreg(matches[1])
			_mode := 3
		}
		else _mode := InStr(_omit, ",") ? 1 : 2
	}
	if _mode
	{
		temp := []
		for i, key in keys
		{
			if __xblock_input_omit(key, _omit, _mode)
				continue
			temp.push(key)
		}
		keys := temp
		temp =
	}
	temp =
	hkeys := []
	_keys := {Ctrl: "^", Shift: "+", Alt: "!", Win: "#"}
	for k, v in _keys
	{
		if _mode && __xblock_input_omit(k, _omit, _mode)
			continue
		for i, key in keys
		{
			hkey := "*" v key
			hkeys[hkey] := hkey
			temp .= ", " hkey
		}
	}
	_keys =
	for i, key in keys
	{
		hkey := "*" (StrLen(key) == 1 ? "$" : "") key
		hkeys[hkey] := hkey
		temp .= ", " hkey
	}
	temp := ltrim(temp, " ,")
	MsgBox, 262196, Block Input?, %temp%
	temp =
	IfMsgBox, No
		return
	if hkeys.Count()
	{
		if _omit_windows !=
		{
			if (isObject(_wins := dsv(_omit_windows)) && _wins.Length())
			{
				tmode := A_TitleMatchMode
				SetTitleMatchMode, 2
				for i, win in _wins
					Hotkey, IfWinNotActive, %win%
			}
			_wins =
		}
		for i, hkey in hkeys
		{
			temp .= (temp == "" ? "" : ", ") hkey
			Hotkey, %hkey%, %handler%, On
		}
	}
	return true
}

__xblock_input_omit(value, ByRef _test, ByRef _mode){
	omit := true
	if (_mode == 1)
		omit := xcontains(value, _test)
	else if (_mode == 2)
		omit := InStr(value, _test)
	else if (_mode == 3)
		omit := RegExMatch(value, _test)
	;_xmsg("__xblock_input_omit: " value " > " _test " > " _mode " = " omit)
	return omit
}

__xblock_input_handler(){
	xtooltip("Block Input, Blocked: " A_ThisHotkey)
}

;imports
#Include <xreg>
#Include <xcontains>

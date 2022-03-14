xxmsg(title := "", message := "", buttons := "", callback := "", owner_gui := "", events := false){
	global _xmsg_owner, _xmsg_owner_hwnd, _xmsg_callback, _xmsg_events, _xmsg_buttons_map, xmsg_action, xmsg_action_index
	_xmsg_events := !!events
	if !(isLabel(callback) || isFunc(callback))
		return
	_xmsg_callback := callback
	if !IsObject(buttons)
	{
		temp := []
		loop, parse, buttons, CSV
		{
			if !(btn := xtrim(A_LoopField))
				continue
			temp.Insert(btn)
		}
		buttons := temp
		temp =
	}
	buttons_count := buttons.Count()
	if !((message := xtrim(message)) || buttons_count)
		return
	if (_xmsg_owner := xtrim(owner_gui))
		Gui, %_xmsg_owner%: +HWND_xmsg_owner_hwnd
	if (!(title := xtrim(title)) && _xmsg_owner_hwnd)
	{
		WinGetTitle, temp, ahk_id %_xmsg_owner_hwnd%
		title := xtrim(temp)
	}
	gosub, _xmsg_close
	gap := 5
	cw := 240
	gw := 265
	Gui, _xmsg_: +LastFound
	_xmsg_hwnd := WinExist()
	Gui, _xmsg_: +ToolWindow
	Gui, _xmsg_: Font, S8 CDefault, Verdana
	Gui, _xmsg_: Add, Edit, x0 y0 w0 h0,
	if message !=
		Gui, _xmsg_: Add, Text, x12 y+%gap% w%cw%, % message
	_xmsg_buttons_map := Object()
	if buttons_count
	{
		eof := false, i := 1
		loop
		{
			if eof
				break
			rem := buttons_count - (i - 1)
			if (rem > 2 && strlen(xtrim(buttons[i])) <= 8 && strlen(xtrim(buttons[i + 1])) <= 8 && strlen(xtrim(buttons[i + 2])) <= 8)
				bc := 3
			else if (strlen(xtrim(buttons[i])) <= 14 && strlen(xtrim(buttons[i + 1])) <= 14)
				bc := 2
			else bc := 1
			bx := "x12"
			by := "y+" (i == 1 ? gap * 2 : gap)
			bw := floor((cw - ((bc - 1) * gap)) / bc)
			loop, % bc
			{
				n := i + (A_Index - 1)
				if (n > buttons_count)
				{
					eof := true
					break
				}
				button := xtrim(buttons[n])
				_xmsg_buttons_map[button] := n
				Gui, _xmsg_: Add, Button, %bx% %by% w%bw% h30 g_xmsg_on_button, % button
				bx := "x+" gap
				by := "yp"
			}
			if eof
				break
			i := n + 1
			if (i > buttons_count)
				break
		}
	}
	Gui, _xmsg_: Add, Text, x0 y+%gap% w0 h0, ;space
	if (_xmsg_owner && _xmsg_owner_hwnd)
	{
		WinGetPos, x, y, w,, ahk_id %_xmsg_owner_hwnd%
		Gui, _xmsg_: Show, y-400 w265, % title
		WinGetPos,,, xw, xh, ahk_id %_xmsg_hwnd%
		sw := A_ScreenWidth
		sh := A_ScreenHeight
		xx := (xx := round(x + (w / 2) - (xw / 2), 0)) >= sw ? sw - xw : (xx <= 0 ? 0 : xx)
		xy := (xy := round(y + (xh / 2), 0)) >= sh ? sh - xh : (xy <= 0 ? 0 : xy)
		WinMove, ahk_id %_xmsg_hwnd%,, %xx%, %xy%
		Gui, %_xmsg_owner%: +Disabled
	}
	else Gui, _xmsg_: Show, w265, % title
	if _xmsg_events
	{
		xmsg_action := "xmsg_show"
		gosub, _xmsg_do_callback
	}
	return
	
	_xmsg_GuiEscape:
	_xmsg_GuiClose:
	if _xmsg_events
	{
		xmsg_action := "xmsg_cancel"
		gosub, _xmsg_do_callback
	}
	_xmsg_close:
	if (_xmsg_owner && _xmsg_owner_hwnd)
		Gui, %_xmsg_owner%: -Disabled
	Gui, _xmsg_: Destroy
	return
	
	_xmsg_on_button:
	xmsg_action := xtrim(A_GuiControl)

	_xmsg_do_callback:
	if !(xmsg_action := xtrim(xmsg_action))
		return
	is_event := false
	if _xmsg_events
	{
		if xmsg_action in xmsg_show,xmsg_cancel
			is_event := true
	}
	if !is_event
		gosub, _xmsg_close
	else Gui, _xmsg_: +OwnDialogs
	if (isObject(_xmsg_buttons_map) && _xmsg_buttons_map.HasKey(xmsg_action))
		xmsg_action_index := _xmsg_buttons_map[xmsg_action]
	if isLabel(_xmsg_callback)
		gosub, %_xmsg_callback%
	else if IsFunc(_xmsg_callback)
		%_xmsg_callback%(xmsg_action, xmsg_action_index)
	return
}

#Include <xtrim>
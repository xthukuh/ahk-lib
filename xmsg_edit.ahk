/*
	Msg Edit
	By Martin Thuku (2021-07-02 19:06:11)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

;includes
;#Include %A_LineFile%\..\xedit_scroll_bottom.ahk

;xmsg_edit
xmsg_edit(text
	, title := "Untitled"
	, exit := 0
	, btn_ok := "&OK"
	, btn_ok_handler := ""
	, btn_cancel := "&Cancel"
	, btn_cancel_handler := "")
{
	global _msg_edit_id
	global _msg_edit_exit
	global _msg_edit_action
	global _msg_edit_ok_handler
	global _msg_edit_cancel_handler
	global _msg_edit_text
	_msg_edit_ok_handler := btn_ok_handler
	_msg_edit_cancel_handler := btn_cancel_handler
	_msg_edit_exit := exit
	_msg_edit_action := ""
	Gui, _msg_edit_: Destroy
	Gui, _msg_edit_: +LastFound ;+LabelGui
	_msg_edit_id := WinExist()
	Gui, _msg_edit_: Add, Edit, x0 y0 w0 h0,
	Gui, _msg_edit_: Add, Edit, x12 y12 w400 h300 v_msg_edit_text, % text
	Gui, _msg_edit_: Add, Button, x+-100 y+10 w100 h30 g_msg_edit_ok Default, % btn_ok
	Gui, _msg_edit_: Add, Button, xp-110 yp w100 h30 g_msg_edit_cancel, % btn_cancel
	Gui, _msg_edit_: Show,, % title
}

;xmsg edit update text
xmsg_edit_text(text, append := 1){
	global _msg_edit_id
	global _msg_edit_text
	Gui, _msg_edit_: Default
	;xedit_append(_msg_edit_id, text)
	GuiControl, -Redraw, _msg_edit_text
	GuiControl, -VScroll, _msg_edit_text
	if append
	{
		GuiControlGet, old_text,, _msg_edit_text
		text := text "`n" old_text
		;text := old_text "`n" text
	}
	GuiControl,, _msg_edit_text, % text
	;xedit_scroll_bottom("_msg_edit_text", _msg_edit_id)
	GuiControl, +VScroll, _msg_edit_text
	GuiControl, +Redraw, _msg_edit_text
	;*/
}

;cancel
_msg_edit_cancel(){
	global _msg_edit_cancel_handler
	if IsFunc(_msg_edit_cancel_handler)
		%_msg_edit_cancel_handler%(0)
	else _msg_edit_close(0)
}

;ok
_msg_edit_ok(){
	global _msg_edit_ok_handler
	if IsFunc(_msg_edit_ok_handler)
		%_msg_edit_ok_handler%(1)
	else _msg_edit_close(1)
}

;close
_msg_edit_GuiClose(){
	_msg_edit_close()
}

_msg_edit_GuiEscape(){
	_msg_edit_close()
}

_msg_edit_close(action := ""){
	global _msg_edit_id
	global _msg_edit_exit
	global _msg_edit_action
	_msg_edit_action := action
	Gui, _msg_edit_: Destroy
	if _msg_edit_exit
		ExitApp
	_msg_edit_id =
}
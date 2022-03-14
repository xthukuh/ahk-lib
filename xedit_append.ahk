;edit append text
xedit_append(hwnd, text){
	str := text
    SendMessage, 0x000E, 0, 0,, ahk_id %hwnd% ;WM_GETTEXTLENGTH
    SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hwnd% ;EM_SETSEL
    SendMessage, 0x00C2, False, &str,, ahk_id %hwnd% ;EM_REPLACESEL
	xmsg("str: " str " - " &str "`nhwnd: " hwnd)
}

/*
MsgBox, % "The GUI will take time to show. Please be patient..."
    
;Put 60000 characters in the textbox
Gui, Add, Edit, r10 w500 hwndhMyEdit vMyEdit, % GenText("a", 60000)
Gui, Add, Button, xm w245 gbtnNormal, Append using GuiControlGet
Gui, Add, Button, x+10 w245 gbtnFast, AppendText()
Gui, Show

;Scroll to bottom
SendMessage, 0x0115, 7, 0,, ahk_id %hMyEdit% ;WM_VSCROLL    
Return

btnNormal:
    GuiControlGet, sCurrentText,, MyEdit
    GuiControl,, MyEdit, %sCurrentText% Appended!
    
    ;Scroll to bottom
    SendMessage, 0x0115, 7, 0,, ahk_id %hMyEdit% ;WM_VSCROLL
Return

btnFast:
    sAppend := " Appended!"
    AppendText(hMyEdit, &sAppend)
    
    ;Scroll to bottom
    SendMessage, 0x0115, 7, 0,, ahk_id %hMyEdit% ;WM_VSCROLL
Return

GuiEscape:
GuiClose:
ExitApp

GenText(char, n) {
    VarSetCapacity(s, n, Asc(char))
    NumPut(0, s, n, "UChar")
    VarSetCapacity(s, -1)
    Return s
}

AppendText(hEdit, ptrText) {
    SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
    SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit% ;EM_SETSEL
    SendMessage, 0x00C2, False, ptrText,, ahk_id %hEdit% ;EM_REPLACESEL
}
;https://support.microsoft.com/kb/109550
*/
/*
Gui, Add, Edit, hwndhEdit w300 r15, The Quick Brown Fox Jumps Over The Lazy Dog
Gui, Show,, Prepend Text in Edit Control

Loop {
If ( Time <> A_Now )
Time := A_Now
, Edit_Prepend( hEdit, Time "`r`n" )
Sleep 500
}

GuiClose:
ExitApp

Edit_Prepend( hEdit, Text ) { ;www.autohotkey.com/community/viewtopic.php?p=565894#p565894
DllCall( "SendMessage", UInt,hEdit, UInt,0xB1, UInt,0 , UInt,0 ) ; EM_SETSEL
DllCall( "SendMessage", UInt,hEdit, UInt,0xC2, UInt,0 , UInt,&Text ) ; EM_REPLACESEL
DllCall( "SendMessage", UInt,hEdit, UInt,0xB1, UInt,0 , UInt,0 ) ; EM_SETSEL
}
*/

/*
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%  

Gui, Add, Edit, hwndhEdit w300 r15, Logging Data`n-----------------------`n
Gui, Show,, Insert Text in Edit Control

Loop {
 If ( Time <> A_Now )
      Time := A_Now
    , Edit_Insert( hEdit, Time "`r`n" , 39 )
 Sleep 500
}

GuiClose:
 ExitApp

Edit_Insert( hEdit, Text, @=0 ) {
; www.autohotkey.com/community/viewtopic.php?p=566713#p566713
  DllCall( "SendMessage", UInt,hEdit, UInt,0xB1, UInt,@ , UInt,@     )     ; EM_SETSEL
  DllCall( "SendMessage", UInt,hEdit, UInt,0xC2, UInt,0 , UInt,&Text )     ; EM_REPLACESEL
  DllCall( "SendMessage", UInt,hEdit, UInt,0xB1, UInt,@ , UInt,@     )     ; EM_SETSEL
}
*/
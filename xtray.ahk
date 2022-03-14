/*
	Tray Icon/Menu Helper
	By Martin Thuku (2021-05-28 00:28:59)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io

	Globals:
	script_show_options
	script_about
	script_icon
	script_title
*/

;tray defaults
xtray_defaults(menu_items := "", ico := "", show_title := "&Show Options", show_handler := "xtray_on_show_options"){
	tray_menu := []
	if (show_title != "" && (IsFunc(show_handler) || IsLabel(show_handler))) 
		tray_menu.Push([show_title, show_handler, 1])
	if (isObject(menu_items) && menu_items.Length())
		tray_menu.Push(menu_items*)
	tray_menu.Push([""
		, ["&About", "xtray_on_about"]
		, ["&Reload", "xtray_on_reload"]
		, ["&Quit", "xtray_on_quit"]]*)
	xtray_menu(tray_menu)
	xtray_icon(ico)
	xtray_tip()
}

;tray menu - show options
xtray_on_show_options(){
	global script_show_options
	if IsFunc(script_show_options)
		%script_show_options%()
	else if IsLabel(script_show_options)
		Gosub, %script_show_options%
	else xtraytip_error("Tray show handler is undefined.")
}

;tray menu - quit
xtray_on_quit(){
	ExitApp
}

;tray menu - reload
xtray_on_reload(){
	Reload
}

;tray menu - about
xtray_on_about(){
	global script_about
	about =
	( LTrim
		By Martin Thuku
		@support - xthukuh@gmail.com
		https://fiverr.com/martinthuku
		https://xthukuh.github.io
	)
	if ((msg := xtrim(script_about)) != "")
	{
		if InStr(msg, "{about}")
			msg := StrReplace(msg, "{about}", about)
	}
	else msg := about
	xalert_info(msg,,, "TOP")
}

;tray tip
xtray_tip(msg := ""){
	global script_title
	if ((msg := xtrim(msg)) == "")
		msg := xtrim(script_title)
	if msg =
		msg := A_ScriptName
	if msg !=
		Menu, Tray, Tip, % msg
}

;tray icon
xtray_icon(ico := ""){
	global script_icon
	if ((ico := xtrim(ico)) == "")
		ico := xtrim(script_icon)
	if ico !=
		Menu, Tray, Icon, % ico
}

;tray menu [...["&Menu Name", "_handler", is_default := 1]]
xtray_menu(items, tray_click := 1, no_default := 1, no_standard := 1){
	;setup menu items
	menu_items := []
	if (isObject(items) && (len := items.Length()))
	{
		loop, % len
		{
			item := items[A_Index]
			if (isObject(item) && item.Length() >= 2)
				menu_items.Insert(item)
			if (item == "" && (n := menu_items.Length()) && menu_items[n] != "")
				menu_items.Insert("")
		}
	}
	
	;remove empty last menu item
	if ((n := menu_items.Length()) && menu_items[n] == "")
		menu_items.Delete(n)
	
	;ignore menu items empty
	if !(len := menu_items.Length())
		return

	;setup tray menu
	Menu, Tray, DeleteAll
	if no_default
		Menu, Tray, NoDefault
	if no_standard
		Menu, Tray, NoStandard
	
	;set tray menu
	default_menu := ""
	loop, % len
	{
		;menu item
		item := menu_items[A_Index]
		if (isObject(item) && item.Length() >= 2)
		{
			;["Menu Name", "_menu_handler", _is_default := 0]
			menu_name := item[1]
			menu_handler := item[2]
			if (item.Length() >= 3 && (item[3] * 1))
				default_menu := menu_name
			Menu, Tray, Add, % menu_name, % menu_handler
		}
		else if (item == "")
		{
			;Separator
			Menu, Tray, Add,
		}
	}

	;set default menu
	if default_menu !=
		Menu, Tray, Default, % default_menu
	
	;set tray click
	if ((tray_click := Floor(tray_click * 1)) >= 1 || tray_click == 2)
		Menu, Tray, Click, % tray_click
}

;traytip info
xtraytip_info(msg, title := "", timeout := 0){
	return xtraytip(msg, title, timeout, "INFO")
}

;traytip warn
xtraytip_warn(msg, title := "", timeout := 0){
	return xtraytip(msg, title, timeout, "WARN")
}

;traytip error
xtraytip_error(msg, title := "", timeout := 0){
	return xtraytip(msg, title, timeout, "ERROR")
}

;traytip
xtraytip(msg, title := "", timeout := 0, options*){
	global script_title
	if ((msg := xtrim(msg)) == "")
	{
		TrayTip
		return
	}
	title := (t := xtrim(title)) != "" ? t : ((t := xtrim(script_title)) != "" ? t : A_ScriptName)
	timeout := (timeout := timeout * 1) ? timeout : ""
	opts := xtraytip_opts(options*)
	TrayTip, % title, % msg, % timeout, % opts
}

;traytip opts
xtraytip_opts(options*){
	static opts
	if !IsObject(opts)
	{
		opts := xtraytip_options().Clone()
		for k, v in opts
			opts[v] := v
	}
	seen =
	sum := 0
	for i, v in options
	{
		if !(v := xtrim(v))
			continue
		StringUpper, v, v
		if v in %seen%
			continue
		if opts.HasKey(v)
		{
			sum += opts[v]
			seen .= (seen != "" ? "," : "") v
		}
		else if (v && options.Length() == 1)
		{
			if v is integer
				sum += v
		}
	}
	return sum
}

;traytip options
xtraytip_options(){
	static opts
	if !isObject(opts)
	{
		opts := {INFO: 1	;info
			, WARN: 2		;warning
			, ERROR: 3		;error
			, SILENT: 16	;do not play sound
			, LARGE: 32}	;use large version of icon
	}
	return opts
}

;requires
#Include *i %A_LineFile%\..\xtrim.ahk
#Include *i %A_LineFile%\..\xalert.ahk
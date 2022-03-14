/*
	MsgBox Helper
	By Martin Thuku (2021-05-19 23:01:34)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io

	Globals:
	script_title
	script_dialog_owner
*/

;alert - info icon
xalert_info(msg, title := "", timeout := 0, options*){
	opts := ["INFO"]
	opts.Insert(options*)
	return xalert(msg, title, timeout, opts*)
}

;alert - warning icon
xalert_warn(msg, title := "", timeout := 0, options*){
	opts := ["WARNING", "TOP"]
	opts.Insert(options*)
	return xalert(msg, title, timeout, opts*)
}

;alert - stop icon
xalert_danger(msg, title := "", timeout := 0, options*){
	opts := ["STOP", "TOP"]
	opts.Insert(options*)
	return xalert(msg, title, timeout, opts*)
}

;alert confirm - question icon
xalert_confirm(msg, title := "", timeout := 0, options*){
	opts := ["QUESTION", "YES_NO"]
	opts.Insert(options*)
	return (xalert(msg, title, timeout, opts*) == "Yes")
}

;alert confirm - warning icon
xalert_confirm_warn(msg, title := "", timeout := 0, options*){
	opts := ["WARNING", "YES_NO"]
	opts.Insert(options*)
	return (xalert(msg, title, timeout, opts*) == "Yes")
}

;alert (msgbox)
xalert(msg, title := "", timeout := 0, options*){
	global script_title ;default alert title (A_ScriptName)
	global script_dialog_owner ;gui name
	if !(msg := xtrim(msg))
		return
	title := (t := xtrim(title)) != "" ? t : ((t := xtrim(script_title)) != "" ? t : A_ScriptName)
	if ((script_dialog_owner := xtrim(script_dialog_owner)) != "")
		Gui, %script_dialog_owner%: +OwnDialogs
	else
		Gui, +OwnDialogs
	timeout := (timeout := timeout * 1) ? timeout : "" 
	opts := xalert_opts(options*)
	MsgBox, % opts, % title, % msg, % timeout
	IfMsgBox, Yes
		return "Yes"
	IfMsgBox, No
		return "No"
	IfMsgBox, Cancel
		return "Cancel"
	IfMsgBox, Abort
		return "Abort"
	IfMsgBox, Ignore
		return "Ignore"
	IfMsgBox, Retry
		return "Retry"
	IfMsgBox, Timeout
		return "Timeout"
	IfMsgBox, Continue
		return "Continue"
	IfMsgBox, TryAgain
		return "TryAgain"
}

;alert (msgbox) options
xalert_options(){
	static opts
	if !isObject(opts)
	{
		opts := {HELP: 16384
			, RIGHT: 524288
			, RTL: 1048576
			, BTN_2: 256
			, BTN_3: 512
			, BTN_4: 768
			, SYSTEM: 4096
			, TASK: 8192
			, TOP: 262144
			, OK_CANCEL: 1
			, ABORT_RETRY: 2
			, YES_NO_CANCEL: 3
			, YES_NO: 4
			, RETRY_CANCEL: 5
			, TRY_AGAIN: 6
			, STOP: 16
			, INFO: 64
			, QUESTION: 32
			, WARNING: 48}
	}
	return opts
}

;alert opts - sum options
xalert_opts(options*){
	static opts
	if !IsObject(opts)
	{
		opts := xalert_options().Clone()
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

;requires
#Include *i %A_LineFile%\..\xtrim.ahk
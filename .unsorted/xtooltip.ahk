class xtooltip_timeout {
	interval {
		get {
			num := this.__interval
			if num is not number
				num := 0
			return (num * 1)
		}
		set {
			value := xtrim(value)
			if value is not number
				value := 0
			return this.__interval := value
		}
	}
	which {
		get {
			num := this.__which
			if num is not number
				num := 0
			return (num * 1)
		}
		set {
			value := xtrim(value)
			if value is not number
				value := 0
			return this.__which := value
		}
	}
    __New(interval := "", which := ""){
        this.interval := interval
		this.which := which
        this.timer := ObjBindMethod(this, "Call")
		this.ready := false
		this.listening := false
    }
    Start(){
		timer := this.timer
		if this.ready
		{
			SetTimer % timer, On
			return
		}
		if !(interval := this.interval)
			return this.Stop()
        SetTimer, % timer, % interval
		this.listening := true
		this.ready := true
    }
    Stop(){
		if !this.listening
			return
        timer := this.timer
        SetTimer % timer, Off
		this.listening := false
    }
    Call(){
		which := this.which
		interval := this.interval
		xtooltip_hide(which)
		if (interval && interval < 0)
			this.listening := false
    }
}

xtooltip(text := "", timeout := "", x := "", y := "", which := "1"){
	global __xtooltip_count, __xtooltip_tips
	if !isObject(__xtooltip_count)
		__xtooltip_count := Object()
	if !isObject(__xtooltip_tips)
		__xtooltip_tips := Object()
	text := xtrim(text)
	if text !=
	{
		if !((which := xtrim(which)) != "" && (which := aint(which)) > 0 && which <= 20)
			which := xtooltip_which()
		if !which
			return
		x := x && (x := xint(x, "")) != "" ? x : ""
		y := y && (y := xint(y, "")) != "" ? y : ""
		ToolTip, %text%, %x%, %y%, %which%
		__xtooltip_tips[which] := which
		if ((timeout := timeout && (timeout := abs(xnum(timeout))) > 0 ? timeout * -1 : "") != "")
		{
			timeout := new xtooltip_timeout(timeout, which)
			timeout.Start()
		}
		return which
	}
	return xtooltip_hide(which)
}

xtooltip_hide(which := ""){
	global __xtooltip_count, __xtooltip_tips
	if ((which := xtrim(which)) != "" && (which := aint(which)) > 0 && which <= 20)
	{
		ToolTip,,,, %which%
		if (isObject(__xtooltip_count) && __xtooltip_count.HasKey(which))
			__xtooltip_count.delete(which)
		if (isObject(__xtooltip_tips) && __xtooltip_tips.HasKey(which))
			__xtooltip_tips.delete(which)
		return -%which%
	}
	ToolTip
}

xtooltip_which(){
	global __xtooltip_count
	n := 0, max := (__xtooltip_count.Count() ? __xtooltip_count.MaxIndex() : 0) + 1
	loop, % max
	{
		n := A_Index
		if !__xtooltip_count.HasKey(n)
			break
	}
	if (n > 20)
	{
		MsgBox, 262196, Create Tooltip - %A_ScriptName%, You have reached maximum number of tooltips (20)`nReset counter and retry?
		IfMsgBox, Yes
		{
			__xtooltip_count := Object()
			return xtooltip_which()
		}
	}
	return n > 0 && n <= 20 ? (__xtooltip_count[n] := n) : 0
}


#Include <xtrim>
#Include <xint>
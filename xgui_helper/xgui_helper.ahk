/*
	XGUI Helper
	By Martin Thuku (2021-07-11 20:10:02)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

;includes
#Include *i %A_LineFile%\..\..\xtrim.ahk
#Include *i %A_LineFile%\..\..\xnum.ahk
#Include %A_LineFile%\..\xgui_helper_ctrl.ahk
#Include %A_LineFile%\..\xgui_helper_cls.ahk
#Include %A_LineFile%\..\xgui_helper_sb.ahk

;xgui helper
class xgui_helper extends xgui_helper_cls
{
	;new instance
	__New(name := "", title := "", close_exitapp := false, cancel_close := false)
	{
		;properties
		this._pos := [0, 0] ;[x, y]
		this._size := [0, 0, ""] ;[width, height, event_info]
		this._margin := 10
		this._title := (title := xtrim(title))
		this._shown := 0
		this._owner := ""
		this._owner_disable := 0
		this._exitapp := (close_exitapp := !!close_exitapp)
		this._cancel_close := (cancel_close := !!cancel_close)
		this._callbacks := {}
		this._resize := ""
		this._min_size := [0, 0] ;[width, height]
		this._max_size := [0, 0] ;[width, height]
		this._min_box := ""
		this._max_box := ""
		this._always_on_top := ""
		this._border := ""
		this._caption := ""
		this._delimiter := "|"
		this._disabled := ""
		this._label := ""
		this._sys_menu := ""
		this._theme := ""
		this._tool_window := ""
		this._flash := ""
		this._children := []
		this._children_map := {}
		this._children_size := {w: 0, h: 0}
		this._children_autosize := []

		;new gui
		name := this.new_instance(name)
		Gui, %name%: New,, %title%
		Gui, %name%: +HWND_gui_hwnd
		if !(_gui_hwnd >= 1)
			throw "XGui Builder Gui, " name ": +HWND failure."
		this.set_id(_gui_hwnd) ;this._id
		this.label("xgui_helper_on_")
		this.margin(this._margin)
		this.default(1)
	}

	;get gui helper
	gui()
	{
		return this
	}

	;get/set position
	pos(x := "", y := "")
	{
		if !(isObject(this._pos) && this._pos.Length() >= 2)
			this._pos := [0, 0]
		x := (x := xtrim(x)) != "" ? (this._pos[1] := xnum(x)) : xnum(this._pos[1])
		y := (y := xtrim(y)) != "" ? (this._pos[2] := xnum(y)) : xnum(this._pos[2])
		return [x, y]
	}

	;get/set size
	size(w := "", h := "", event_info := "")
	{
		;init size
		if !(isObject(this._size) && this._size.Length() >= 3)
			this._size := [0, 0, ""]
		
		;get size
		w := xtrim(w)
		h := xtrim(h)
		if !(w != "" || h != "")
			return this._size

		;new size
		if !(id := this.id())
			return

		w := w != "" ? xnum(w) : xnum(this._size[1])
		h := h != "" ? xnum(h) : xnum(this._size[2])
		e := (e := xtrim(event_info)) != "" ? e : xtrim(this._size[3])
		
		;on size callback
		this.own_dialogs()
		if (res := this.callback("size", [id, e, w, h, this]*))
			return res
		
		;set size - redraw
		old_w := xnum(this._size[1])
		old_h := xnum(this._size[2])
		if (old_w && old_h && e != 1)
		{
			dw := w - old_w
			dh := h - old_h
			this.redraw(dw, dh)
		}
		return (this._size := [w, h, e])
	}

	;redraw
	redraw(dw, dh)
	{
		loop, % this._children.Length()
		{
			child := this._children[A_Index]
			pos := child.pos()
			grow := child.grow()
			mv := ""
			if grow contains x
			{
				mx := pos.x + dw
				mv .= " x" mx
			}
			if grow contains y
			{
				my := pos.y + dh
				mv .= " y" my
			}
			if grow contains w
			{
				mw := pos.w + dw
				mv .= " w" mw
			}
			if grow contains h
			{
				mh := pos.h + dh
				mv .= " h" mh
			}
			if ((mv := xtrim(mv)) != "")
				child.move(mv, 1)
		}
	}

	;get/set margin
	margin(m := "")
	{
		if ((name := this.name()) && (m := xtrim(m)) != "")
		{
			m := this._margin := anum(m)
			Gui, %name%: Margin, % m
		}
		else m := anum(this._margin)
		return m
	}

	;exitapp << self
	exitapp(val := 1)
	{
		if val in 0,1,2
			this._exitapp := val
		return this
	}

	;on size << self - callback args = [GuiHwnd, EventInfo, Width, Height, self]*
	on_size(callback, _multiple := 0)
	{
		return this.set_callback("size", callback, _multiple)
	}

	;on close << self - callback args = [id, self]*
	on_close(callback, _multiple := 0)
	{
		return this.set_callback("close", callback, _multiple)
	}

	;close
	close()
	{
		if !(id := this.id())
			return
		
		;on close callback
		this.own_dialogs()
		if (res := this.callback("close", [id, this]*))
			return res
		
		;destroy - exitapp
		this.destroy()
		if this._exitapp
			ExitApp
	}

	;on cancel << self - callback args = [id, self]*
	on_cancel(callback, _multiple := 0)
	{
		return this.set_callback("cancel", callback, _multiple)
	}

	;cancel
	cancel()
	{
		if !(id := this.id())
			return
		
		;on cancel callback
		this.own_dialogs()
		if (res := this.callback("cancel", [id, this]*))
			return res
		
		;cancel close
		if this._cancel_close
			return this.close()

		;hide
		this.hide()
	}

	;on contextMenu << self - callback args = [GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y, self]*
	on_contextMenu(callback, _multiple := 0)
	{
		return this.set_callback("contextMenu", callback, _multiple)
	}

	;context menu
	contextMenu(ctrl_id, event_info, is_right_click, x, y)
	{
		if !(id := this.id())
			return
		
		;on contextMenu callback
		this.own_dialogs()
		if (res := this.callback("contextMenu", [id, ctrl_id, event_info, is_right_click, x, y, this]*))
			return res
	}

	;on dropFiles << self - callback args = [GuiHwnd, FileArray, CtrlHwnd, X, Y, self]*
	on_dropFiles(callback, _multiple := 0)
	{
		return this.set_callback("dropFiles", callback, _multiple)
	}

	;drop files
	dropFiles(file_array, ctrl_id, x, y)
	{
		if !(id := this.id())
			return
		
		;on dropFiles callback
		this.own_dialogs()
		if (res := this.callback("dropFiles", [id, file_array, ctrl_id, x, y, this]*))
			return res
	}

	;title
	title(title := "")
	{
		id := this.id(0)
		if ((title := xtrim(title)) != "")
		{
			if (id && this._shown)
			{
				tmp := A_DetectHiddenWindows
				DetectHiddenWindows, On
				WinSetTitle, ahk_id %id%,, %title%
				DetectHiddenWindows, %tmp%
			}
			this._title := title
		}
		else if (id && this._shown)
		{
			title := xtrim(this._title)
			tmp := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinGetTitle, win_title, ahk_id %id%
			DetectHiddenWindows, %tmp%
			win_title := xtrim(win_title)
			if (win_title != "" && win_title != title)
				return this.title(win_title)
		}
		return xtrim(this._title)
	}

	;check if win exists
	exists(ByRef is_hidden := "")
	{
		is_hidden := ""
		if !(id := this.id())
			return
		tmp := A_DetectHiddenWindows
		DetectHiddenWindows, On
		if (exists := WinExist("ahk_id " id))
		{
			DetectHiddenWindows, Off
			is_hidden := !WinExist("ahk_id " id)
		}
		DetectHiddenWindows, % tmp
		return exists
	}

	;WinHide << self
	win_hide()
	{
		if !(id := this.id())
			return this
		WinHide, ahk_id %id%
		return this
	}

	;WinShow << self
	win_show()
	{
		if !(id := this.id())
			return this
		this.win_hide()
		WinShow, ahk_id %id%
		return this
	}

	;WinMinimize
	win_min()
	{
		if !(id := this.id())
			return this
		WinMinimize, ahk_id %id%
		return this
	}

	;WinMaximize << self
	win_max()
	{
		if !(id := this.id())
			return this
		WinMaximize, ahk_id %id%
		return this
	}

	;WinRestore << self
	win_restore()
	{
		if !(id := this.id())
			return this
		this.win_show()
		WinRestore, ahk_id %id%
		return this
	}

	;WinActivate << self
	win_activate()
	{
		if !(id := this.id())
			return this
		this.win_restore()
		WinActivate, ahk_id %id%
		return this
	}

	;WinWait/WinWaitActive << self
	win_wait(_active := false)
	{
		if !(id := this.id())
			return this
		if _active
			WinWaitActive, ahk_id %id%
		else
			WinWait, ahk_id %id%
		return this
	}

	;WinSet << self
	win_set(cmd := "", value := "")
	{
		if !(id := this.id())
			return this
		WinSet, %cmd%, %value%, ahk_id %id%
		return this
	}

	;check if win is hidden
	hidden()
	{
		return this.exists(is_hidden) && is_hidden
	}

	;check if win is showing
	showing()
	{
		return this.exists(is_hidden) && !is_hidden
	}

	;show << self
	show(options := "", title := "")
	{
		if !((name := this.name()) && (id := this.id())) 
			return this
		
		title := this.title(title)
		if !this._shown
		{
			options := xtrim(options)
			Gui, %name%: Show, % options, % title
			this._shown := 1
			return this
		}
		else return this.win_restore()
	}

	;hide << self
	hide()
	{
		if !(id := this.id())
			return this
		WinHide, ahk_id %id%
		return this
	}

	;submit << self
	submit(_nohide := "NoHide")
	{
		if !(name := this.name())
			return this
		Gui, %name%: Submit, % _nohide
		return this
	}

	;destroy << self
	destroy()
	{
		if !(name := this.name())
			return this
		
		;gui destroy
		Gui, %name%: Destroy
		
		;unset owner
		this.owner()

		;unset instance
		this.unset_instance(name)
		
		;return self
		return this
	}

	;owner << self
	owner(xname := "", _disable := false, ByRef xowner := "")
	{
		xowner := ""
		if !(name := this.name())
			return this
		
		;set owner
		if (xowner := this.get_instance(xname))
		{
			xname := xowner.name()
			if _disable
				xowner.disabled()
			Gui, %name%: +Owner%xname%
			this._owner_disable := !!_disable
			this._owner := xname
		}

		;unset owner
		else if ((xname := xtrim(this._owner)) != "")
		{
			Gui, %name%: -Owner%xname%
			if (xowner := this.get_instance(xname))
			{
				if this._owner_disable
					xowner.disabled(0)
			}
			this._owner_disable := 0
			this._owner := ""
		}

		;return self
		return this
	}

	;last found << self
	last_found(_exist := true)
	{
		if !(name := this.name())
			return this
		if _exist
			Gui, %name%: +LastFoundExist
		else
			Gui, %name%: +LastFound
		return this
	}

	;option << self - i.e. this.option("+E0x40000") >> WS_EX_APPWINDOW
	option(option)
	{
		if ((option := xtrim(option)) != "" && (name := this.name()))
			Gui, %name%: %option%
		return this
	}
	
	;option toggle << self
	option_toggle(option, val := true)
	{
		if ((option := xtrim(option)) != "")
			return this.option((val ? "+" : "-") option)
		return this
	}

	;default << self - A_DefaultGui
	default(_own_dialogs := false)
	{
		if !(name := this.name())
			return this
		Gui, %name%: Default
		return _own_dialogs ? this.own_dialogs() : this
	}

	;own dialogs << self
	own_dialogs(val := true)
	{
		return this.option_toggle("OwnDialogs", val)
	}

	;resize << self
	resize(val := true)
	{
		this._resize := !!val
		return this.option_toggle("Resize", val)
	}

	;min size << self
	min_size(width := 0, height := 0)
	{
		width := aint(width)
		height := aint(height)
		size := width || height ? (width ? width : "") "x" (height ? height : "") : ""
		option := "+MinSize" size
		this._min_size := [width, height]
		return this.option(option)
	}

	;max size << self
	max_size(width := 0, height := 0)
	{
		width := aint(width)
		height := aint(height)
		size := width || height ? (width ? width : "") "x" (height ? height : "") : ""
		option := "+MaxSize" size
		this._max_size := [width, height]
		return this.option(option)
	}

	;min box << self
	min_box(val := true)
	{
		this._min_box := !!val
		return this.option_toggle("MinimizeBox", val)
	}

	;max box << self
	max_box(val := true)
	{
		this._max_box := !!val
		return this.option_toggle("MaximizeBox", val)
	}

	;always on top << self
	always_on_top(val := true)
	{
		_always_on_top := !!val
		return this.option_toggle("AlwaysOnTop", val)
	}

	;border << self
	border(val := true)
	{
		this._border := !!val
		return this.option_toggle("Border", val)
	}

	;caption << self
	caption(val := true)
	{
		this._caption := !!val
		return this.option_toggle("Caption", val)
	}

	;delimiter << self
	delimiter(val := "|")
	{
		if (val == " ")
			val := "Space"
		else if (val == "`t")
			val := "Tab"
		else if (isObject(val) || val == "")
			val := "|"
		this._delimiter := val
		return this.option("+Delimiter" val)
	}

	;disabled << self
	disabled(val := true)
	{
		this._disabled := !!val
		return this.option_toggle("Disabled", val)
	}

	;label << self
	label(val := "")
	{
		val := (val := xtrim(val)) != "" ? val : "xgui_helper_on_"
		this._label := val
		return this.option("+Label" val)
	}

	;sys menu << self
	sys_menu(val := true)
	{
		this._sys_menu := !!val
		return this.option_toggle("SysMenu", val)
	}

	;theme << self
	theme(val := true)
	{
		this._theme := !!val
		return this.option_toggle("Theme", val)
	}

	;tool window << self
	tool_window(val := true)
	{
		this._tool_window := !!val
		return this.option_toggle("ToolWindow", val)
	}

	;flash << self
	flash(val := true)
	{
		if !(name := this.name())
			return this
		if val
			Gui, %name%: Flash
		else
			Gui, %name%: Flash, Off
		this._flash := !!val
		return this
	}

	;color << self
	color(win_color := "", ctrl_color := "", _win_trans := 0)
	{
		if !(name := this.name())
			return this
		win_color := xtrim(win_color)
		ctrl_color := xtrim(ctrl_color)
		if !(win_color != "" || ctrl_color != "")
			return this
		Gui, %name%: Color, %win_color%, %ctrl_color%
		if (win_color != "" && _win_trans)
			this.trans_color(win_color)
		return this
	}

	;WinSet, TransColor << self
	trans_color(val := "")
	{
		return this.win_set("TransColor", val)
	}

	;font << self
	font(options := "", font_name := "")
	{
		if !(name := this.name())
			return this
		options := xtrim(options)
		font_name := xtrim(font_name)
		if (options != "" || font_name != "")
			Gui, %name%: Font, %options%, %font_name%
		else
			Gui, %name%: Font
		return this
	}

	;add - status bar << self
	add_sb(text := "")
	{
		if !(name := this.name())
			return this
		if (isObject(this._sb) && this._sb.__class == "xgui_helper_sb")
			return this
		Gui, %name%: Add, StatusBar,, % text
		this._sb := new xgui_helper_sb(this)
		return this
	}

	;get status bar - add
	sb(_add_sb := 0)
	{
		if (!(isObject(this._sb) && this._sb.__class == "xgui_helper_sb") && _add_sb)
			this.add_sb()
		return this._sb
	}

	;add control << self
	add(type, options := "", text := "", grow := "", ByRef _ctrl := "")
	{
		if !(name := this.name())
			return this
		
		;add ctrl
		_ctrl := ""
		if !xgui_helper_ctrl.is_instance(_ctrl := new xgui_helper_ctrl(this, type, options, text, grow))
			throw % "Gui, " name ": add ctrl instance failure."
		
		;add child
		_ctrl._index := this._children.Push(_ctrl)
		this._children_map[_ctrl.name()] := _ctrl._index
		this._children_map[_ctrl.id()] := _ctrl._index
		
		;result - self
		return this
	}

	;tab << self
	tab(val := "")
	{
		if !(name := this.name())
			return this
		if ((val := xtrim(val)) != "")
			Gui, %name%: Tab, % val
		else
			Gui, %name%: Tab
		return this
	}

	;child controls
	children(_index := "", ByRef _len := 0)
	{
		_len := 0
		if (isObject(children := this._children) && (_len := children.Length()))
		{
			if (i := xint(_index))
			{
				if xgui_helper_ctrl.is_instance(_ctrl := children[i])
					return _ctrl
			}
			else return children
		}
	}

	;get control
	ctrl(val := "", throwable := false)
	{
		if !(name := this.name())
			return this
		if (isObject(val) && xgui_helper_ctrl.is_instance(val))
			return val
		_ctrl := ""
		if ((val := xtrim(val)) != "" && this._children_map.Count() && this._children.Length())
		{
			if this._children_map.HasKey(val)
				_ctrl := this._children[this._children_map[val]]
			else if ((i := aint(val)) >= 1 && this._children.HasKey(i))
				_ctrl := this._children[i]
		}
		else if (val == "")
			_ctrl := xgui_helper_ctrl
		if xgui_helper_ctrl.is_instance(_ctrl)
			return _ctrl
		if throwable
			throw "Gui, " name ": ctrl """ val """ is undefined."
	}

	;fit control << self
	fit_ctrl(val, width_ctrl := "", height_ctrl := "", fit_margin := "")
	{
		if xgui_helper_ctrl.is_instance(_ctrl := this.ctrl(val))
		{
			m := fit_margin != "" ? anum(fit_margin) : this.margin()
			_ctrl_mv := "", _ctrl_pos := _ctrl.pos(), _hctrl := "", _fit_add := ""
			if (height_ctrl != "" && xgui_helper_ctrl.is_instance(_hctrl := this.ctrl(height_ctrl)))
			{
				_hctrl_pos := _hctrl.pos()
				mh := ((_hctrl_pos.y - _ctrl_pos.y) + _hctrl_pos.h + m)
				if (mh > _ctrl_pos.h)
					_ctrl_mv := "h" mh
			}
			if (width_ctrl != "")
			{
				_wctrl := xgui_helper_ctrl.is_instance(_hctrl) && width_ctrl == height_ctrl ? _hctrl : this.ctrl(width_ctrl)
				if xgui_helper_ctrl.is_instance(_wctrl)
				{
					_wctrl_pos := _wctrl.pos()
					/*
					_ww := _wctrl_pos.x + _wctrl_pos.w
					_cw := _ctrl_pos.x + _ctrl_pos.w
					if (_ww > _cw)
						_ctrl_mv .= " w" _ww
					;xmsg(_ww "," _cw)
					*/
					d := _wctrl_pos.x - _ctrl_pos.x
					mw := (d + _wctrl_pos.w + (d > m ? d : m))
					if (mw > _ctrl_pos.w)
						_ctrl_mv .= " w" mw
				}
			}
			if ((_ctrl_mv := Trim(_ctrl_mv)) != "")
			{
				_ctrl.move(_ctrl_mv)
				_ctrl_pos := _ctrl.pos()
				this.add("Text", "x" _ctrl_pos.x " y" (_ctrl_pos.y + _ctrl_pos.h)  " w" _ctrl_pos.w " h0 Hidden")
			}
		}
		return this
	}

	;menu
	menu()
	{
		;todo: Menu Builder
	}
}

;GuiClose handler
xgui_helper_on_Close(GuiHwnd)
{
	if (instance := xgui_helper.get_instance(GuiHwnd))
		return instance.close()
}

;GuiEscape handler
xgui_helper_on_Escape(GuiHwnd)
{
	if (instance := xgui_helper.get_instance(GuiHwnd))
		return instance.cancel()
}

;GuiSize handler
xgui_helper_on_Size(GuiHwnd, EventInfo, Width, Height)
{
	if (instance := xgui_helper.get_instance(GuiHwnd))
		return instance.size(Width, Height, EventInfo)
}

;GuiContextMenu handler
xgui_helper_on_ContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y)
{
	if (instance := xgui_helper.get_instance(GuiHwnd))
		return instance.contextMenu(CtrlHwnd, EventInfo, IsRightClick, X, Y)
}

;GuiDropFiles handler
xgui_helper_on_DropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y)
{
	if (instance := xgui_helper.get_instance(GuiHwnd))
		return instance.dropFiles(FileArray, CtrlHwnd, X, Y)
}
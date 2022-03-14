/*
	Chrome Debugging Websocket Helper
	By Martin Thuku (2021-05-17 11:47:20)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io

	Globals:
	xchrome_socket_pages
*/

class xchrome
{
	;xconfig instance
	static xconfig := ""

	;User directory (default = A_Temp "\xchrome")
	static user_dir := ""
	
	;Executable path (chrome.exe target path)
	static chrome_exe := ""

	;Debug callback (isFunc) - %debug_callback%(msg, _level, "xchrome")
	static debug_callback := ""
	
	;debug level - (levels = 0, 1, 2) - set higher than 2 to disable debugging.
	static debug_level := 3 ;disabled by default

	;new instance
	__New(host := "127.0.0.1", port := 9222, target_url := "", fn_debug := "")
	{
		this.host := host
		this.port := port
		this.target_url := target_url ;default open url
		this.fn_debug := fn_debug ;instance debug callback - fn(msg, _level)
		this.error := "" ;last error message (debug level > 0)
	}

	;debug
	debug(msg, _level := 0, _type := "xchrome")
	{
		if (_level < this.debug_level)
			return
		if _level
			this.error := msg
		if isFunc(fn := this.fn_debug)
			%fn%(msg, _level, _type)
		if isFunc(fn := this.debug_callback)
			%fn%(msg, _level, _type)
	}

	;get chrome dir
	get_dir(_mkdir := 0)
	{
		if !(dir := xtrim(this.user_dir))
			dir := A_Temp "\xchrome"
		IfNotExist, % dir
		{
			if !_mkdir
				return
			FileCreateDir, % dir
			if ErrorLevel
			{
				this.debug("Failed to create chrome user folder """ dir """.`n" A_LastError)
				return
			}
		}
		return dir
	}

	;get port
	get_port()
	{
		if !(port := Abs(Floor(this.port * 1)))
			port := 9222
		return port
	}

	;get host
	get_host()
	{
		_default := "127.0.0.1"
		if !(host := xtrim(this.host))
			host := _default
		if RegExMatch(host, "O)^(https?://)?([\w\d\.]+)\:?", matches)
			host := xtrim(matches[2])
		return (host := xtrim(host)) ? host : _default
	}

	;config get
	config_get(key, default_val := "")
	{
		if !(isObject(cfg := this.xconfig) && cfg.__class == "xconfig")
			cfg := new xconfig()
		return cfg.data(key, default_val)
	}

	;config set
	config_set(key, val)
	{
		if !(isObject(cfg := this.xconfig) && cfg.__class == "xconfig")
			cfg := new xconfig()
		return cfg.save(key, val)
	}

	;select chrome executable path
	select_chrome()
	{
		if (path := xpath_select("Select your chrome executable file. (chrome.exe)", 1, "Executable (*.exe)"))
		{
			this.chrome_exe := path
			msg := "Chrome executable path has been set to """ path """."
			if this.config_set("chrome_exe", path)
				msg .= "`nConfig has been updated."
			xalert_info(msg)
			return 1
		}
	}

	;open chrome exe in debugging mode
	open_chrome()
	{
		if !(exe := this.config_get("chrome_exe", this.chrome_exe))
			exe := "chrome"
		cmd := exe
		if (dir := this.get_dir(1))
			cmd .= " --user-data-dir=" xcli_esc(dir, 1)
		cmd .= " --remote-debugging-port=" this.get_port()
		cmd .= " --no-first-run"
		cmd .= " --no-default-browser-check"
		if (url := xtrim(this.target_url))
			cmd .= " " xcli_esc(url)
		this.debug("Opening chrome debug mode...`n" cmd)
		Run, %cmd%,, UseErrorLevel
		if ErrorLevel contains ERROR
		{
			err := "(" A_LastError ") Failed to open chrome browser in debugging mode!"
			this.debug(err, 1)
			if xalert_confirm_warn(err "`n`nWould you like to setup chrome.exe path?")
			{
				if this.select_chrome()
					return this.open_chrome()
			}
			return
		}
		if (xalert("Chrome is opening...`n`nClick OK to retry when chrome is ready.",,, 65) != "Cancel")
			return 1
	}

	;get chrome instance pages
	pages()
	{
		this.debug("Get chrome instance...", 1)
		url := "http://" this.get_host() ":" this.get_port() "/json"
		if !(res := xget(url, _error))
		{
			this.debug(_error)
			this.pages_error("Failed to get chrome instance at " url ".", 2)
			return
		}
		if !(isObject(pages := xjson_decode(res)) && pages.Length())
		{
			this.pages_error("Failed to get chrome debug pages at " url ".")
			return
		}
		this.debug("Pages (" pages.Length() ")`n" xjson_encode(pages))
		return pages ;[...{description: "", devtoolsFrontendUrl: "", id: "", title: "", type: "", url: "", webSocketDebuggerUrl: ""}]
	}

	;on pages error
	pages_error(err)
	{
		this.debug(err, 2)
		msg := err
		msg .= "`n`nChrome needs to be running in debugging mode for this to work."
		msg .= "`n`nWould you like to open chrome in debugging mode?"
		if (url := xtrim(this.target_url))
			msg .= "`n`nTarget: " url
		if xalert_confirm_warn(msg)
		{
			if this.open_chrome()
				return this.pages()
		}
	}

	;get page by criteria
	get_page_by(key, value, match_mode := "contains", fn_callback := "", fn_close := "")
	{
		this.debug("get_page_by... (" key "," value "," match_mode ")")
		if !(pages := this.pages())
			return
		if (key = "index" && value >= 1 && value <= pages.MaxIndex())
			pg := pages[value]
		else {
			for i, page in pages
			{
				if ((match_mode == "contains" && InStr(page[key], value))
				|| (match_mode == "startswith" && InStr(page[key], value) == 1)
				|| (match_mode == "regex" && page[key] ~= value)
				|| page[key] = value){
					pg := page
					break
				}
			}
		}
		if !isObject(pg)
			return this.debug("Page not found.")
		this.debug("Found page:`n - title: " pg.title "`n - url: " pg.url "`n - ws:" pg.webSocketDebuggerUrl)
		return new this.page(pg, fn_callback, fn_close, this)
	}

	;chrome page instance
	class page
	{
		;page vars
		id := 0
		socket := 0
		responses := []
		response_timeout := 10000 ;10 sec
		connection_timeout := 10000 ;10 sec

		;new page instance
		__New(ws, fn_callback := "", fn_close := "", parent := "")
		{
			this.fn_callback := fn_callback
			this.fn_close := fn_close
			this.parent := parent
			if (isObject(ws) && ws.HasKey("webSocketDebuggerUrl"))
				ws := ws.webSocketDebuggerUrl
			ws := StrReplace(ws, "localhost", "127.0.0.1")
			if !RegExMatch(ws, "O)//(.+?(?=:)):([0-9]+)", matches)
				return
			this.ws := ws
			this.host := matches[1]
			this.port := matches[2]
		}

		;page debug
		debug(msg, _level := 0)
		{
			if isObject(this.parent)
				this.parent.debug(msg, _level, "xchrome.page")
			else xchrome.debug(msg, _level, "xchrome.page")
		}

		;page connect
		connect()
		{
			;global socket pages
			global xchrome_socket_pages

			;init socket pages
			if !isObject(xchrome_socket_pages)
				xchrome_socket_pages := Object()
			
			;wait to connect
			while (xchrome_socket_pages.HasKey("connecting"))
				sleep, 200
			
			;set connecting
			this.socket := 0
			this.debug("Connecting...", 1)
			xchrome_socket_pages["connecting"] := this
			
			;set socket error handler
			AHKsock_ErrorHandler("xchrome_sock_error")
			
			;socket connect - set timer start
			start := A_TickCount
			if (i := AHKsock_Connect(host := this.host, port := this.port, "xchrome_sock_event"))
			{
				;connection failure - unset connecting
				xchrome_socket_pages.Delete("connecting")
				err := "AHKsock_Connect failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
				return this.debug(err)
			}

			;await connection - timeout
			loop
			{
				;wait delay
				Sleep, 50

				;check socket id
				if this.socket
					break
				
				;timeout check
				if ((ms := A_TickCount - start) >= this.connection_timeout)
				{
					this.debug("Connection timeout (" ms ").")
					break
				}
			}

			;unset connecting
			xchrome_socket_pages.Delete("connecting")

			;check socket connection
			if !this.socket
				return this.debug("Connection failed!", 2)

			;connected - set socket page
			xchrome_socket_pages[this.socket] := this
			this.debug("Connected. (" this.socket ")", 1)

			;socket handshake request
			ws := this.ws
			ws_base := "ws://" host ":" port
			StringReplace, ws_path, ws, %ws_base%,,
			raw_http =
			( LTrim Join`r`n
			GET %ws_path% HTTP/1.1
			Origin: http://%host%
			Host: %host%
			Upgrade: websocket
			Connection: Upgrade
			Sec-WebSocket-Key: DTcRJBfSp8DBi5ZDmMWumA==
			Sec-WebSocket-Version: 13


			)
			size := StrPut(raw_http, "UTF-8") - 1
			VarSetCapacity(request, size)
			StrPut(raw_http, &request, size, "UTF-8")

			;send handshake request
			this.debug("Socket handshake... (" size ")`n" raw_http)
			if (i := AHKsock_ForceSend(this.socket, &request, size))
			{
				err := "AHKsock_ForceSend (handshake) failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
				return this.debug(err, 2)
			}

			;success
			this.debug("Handshake successful.")
			Sleep, 1 ;short delay
			return 1
		}

		;get connection - connect if not connected
		get_connection()
		{
			if (!this.socket && !this.connect())
				return this.debug("Not connected.", 2)
			return this.socket
		}

		;call websocket method
		call(domain_method, params := "", wait_response := 1)
		{
			;check connection
			if !this.get_connection()
				return
			
			;call id
			id := this.id += 1

			;unset call id responses
			this.responses[id] := 0
			
			;call data - json
			data := Object()
			data.id := id
			data.params := params ? params : {}
			data.method := domain_method
			data := xjson_encode(data)

			;send call data - start timer
			start := A_TickCount
			this.debug("Call... (" wait_response ")`n" data, 1)
			if !this.send(data)
				return
			
			;no response wait
			if !wait_response
				return
			
			;await response - check call id responses
			while !this.responses[id]
			{
				;wait delay
				Sleep, 50

				;response timeout
				if ((ms := A_TickCount - start) >= this.response_timeout)
				{
					this.debug("Response timeout (" ms ").")
					break
				}
			}

			;return response data
			response := this.responses.Delete(id)
			return response
		}

		;send websocket data
		send(data, _final := 1, _binary := 0, _masked := 1)
		{
			;data size
			len := StrPut(data, "UTF-8") - 1
			
			;debug
			s := "Send... (" len "," _final "," _binary "," _masked ")"
			s .= "`n" xtrim(data)
			this.debug(s)

			;check connection
			if !this.get_connection()
				return
			
			;unsupported encoding
			if (len >= 0xFFFF)
				return this.debug("Send data is too large (>=" (0xFFFF * 1) ")! Encoding for this size (" len ") is not yet implemented.", 1)
			
			;frame opts - final|opcode|masked|length
			fin := _final ? 0x80 : 0
			opcode := _binary ? 0x02 : 0x01
			masked := _masked ? 0x80 : 0
			length := len < 126 ? len : 126

			;frame pack
			hdr_size := len < 126 ? 6 : 8
			frame_size := len + hdr_size
			VarSetCapacity(text_frame, frame_size, 0)
			NumPut(fin | opcode, text_frame, 0, "uchar")
			NumPut(masked | length, text_frame, 1, "uchar")

			;frame mask - random
			if _masked
			{
				Random mask1, 0, 0xFFFF
				Random mask2, 0, 0xFFFF
				mask := mask1 | (mask2 << 16)
			}

			;frame pack data
			ptr := &text_frame + 2
			if (len < 126)
			{
				if _masked
					this.pack(mask, 4, ptr)
				StrPut(data, ptr + 4, len, "UTF-8")
			}
			else {
				this.pack(len, 2, ptr)
				if _masked
					this.pack(mask, 4, ptr + 2)
				StrPut(data, ptr + 6, len, "UTF-8")
			}

			;frame payload - apply mask
			loop % len
			{
				i := hdr_size + (A_Index - 1)
				t := NumGet(text_frame, i, "uchar")
				m := NumGet(text_frame, hdr_size - 4 + Mod(A_Index - 1, 4), "uchar")
				NumPut(n := t ^ m, text_frame, i, "uchar")
			}

			;send text frame
			this.debug("Sending frame...")
			if (i := AHKsock_ForceSend(this.socket, &text_frame, frame_size))
			{
				err := "AHKsock_ForceSend (data) failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
				return this.debug(err, 2)
			}

			;frame sent
			this.debug("Frame sent.")

			;short delay
			Sleep, 1000

			;send close frame
			this.debug("Send close frame...")
			VarSetCapacity(text_frame, size := 4, 0)
			NumPut(0xe8030288, text_frame, 0, "uint")
			if (i := AHKsock_ForceSend(this.socket, &text_frame, size))
			{
				err := "AHKsock_ForceSend (send close) failed with return value = " i " and error code = " ErrorLevel " at line " A_LineNumber
				return this.debug(err, 1)
			}

			;close frame sent
			this.debug("Close frame sent.")
			return 1
		}

		;text frame - pack num
		pack(num, len, ptr)
		{
			hex := SubStr(Format("{:0" (x := (len * 2)) "x}", num), - (x - 1))
			loop, % len
			{
				h := "0x" SubStr(hex, (A_Index * 2) - 1, 2)
				NumPut(h * 1, ptr + (A_Index - 1), "uchar")
			}
		}

		;disconnect page
		disconnect(msg := "")
		{
			;global socket pages
			global xchrome_socket_pages
			
			;debug disconnect msg
			if msg !=
				this.debug(msg, 2)
			
			;close socket
			AHKsock_Close(this.socket)
			
			;unset socket page
			xchrome_socket_pages.Delete(this.socket)
			this.socket := 0
			
			;debug
			this.debug("Socket closed.")
			
			;call page fn_close callback
			if isFunc(fn := this.fn_close)
				%fn%()
		}

		;socket event handler
		on_event(sEvent, iSocket := 0, sName := 0, sAddr := 0, sPort := 0, ByRef bData := 0, bDataLength := 0)
		{
			;debug
			this.debug("Socket event: " sEvent "|" iSocket "|" bDataLength)
			
			;connection closing
			if (bDataLength = 4 && NumGet(bData, "uint") = 0xe8030288)
			{
				AHKsock_Close(iSocket)
				return this.disconnect("Connection closing gracefully.")
			}

			;event - received
			if (sEvent = "RECEIVED")
			{
				;get string data
				sData := StrGet(&bData, bDataLength, "UTF-8")
				
				;cleanup json
				if (i := InStr(sData, "{"))
					sData := SubStr(sData, i)
				
				;debug
				this.debug("Received (" StrLen(sData) "):`n" xtrim(sData), 1)
				
				;call page fn_callback callback
				if isFunc(fn := this.fn_callback)
					%fn%(sData)

				;parse json
				if (isObject(data := xjson_decode(sData)) && data.HasKey("id"))
				{
					;get data call id
					id := data.id

					;set data result
					res := data
					if res.HasKey("result")
						res := res.result
					if (isObject(res) && res.HasKey("result"))
						res := res.result
					
					;set call id response result
					if this.responses.HasKey(id)
						this.responses[id] := res
				}
			}

			;event - connected (set page socket)
			else if (sEvent = "CONNECTED")
				this.socket := iSocket
			
			;event - disconnected (disconnect)
			else if (sEvent = "DISCONNECTED")
				this.disconnect("Disconnected.")
		}

		;socket error handler
		on_error(iError, iSocket)
		{
			err := "Socket error: " iError " (iSocket: " iSocket ")"
			this.debug(err, 2)
		}

		;page evaluate javascript
		eval(js)
		{
			params := {expression: js
				, objectGroup: "console"
				, includeCommandLineAPI: "!true"
				, silent: "!false"
				, returnByValue: "!true"
				, userGesture: "!true"
				, awaitPromise: "!false"}
			return this.call("Runtime.evaluate", params)
		}

		;page wait load
		wait_load(ready_state := "complete", timeout := 10000, interval := 200)
		{
			;start timer
			state := ""
			start := A_TickCount
			loop
			{
				;get document.readyState result
				if (isObject(res := this.eval("document.readyState")) && res.HasKey("value"))
				{
					;check response state
					if ((state := res.value) = ready_state)
						break
				}
				else break ;break on unexpected response

				;timeout check
				if ((ms := A_TickCount - start) >= timeout)
				{
					this.debug("wait load timeout (" ms ").")
					break
				}

				;wait interval
				Sleep, % interval
			}

			;return final state
			return state
		}

		;page browser version
		version()
		{
			return this.call("Browser.getVersion")
		}
	}
}

;get socket page
xchrome_sock_page(iSocket){
	global xchrome_socket_pages
	if !isObject(xchrome_socket_pages)
		return
	if xchrome_socket_pages.HasKey(iSocket)
		return xchrome_socket_pages[iSocket]
	if xchrome_socket_pages.HasKey("connecting")
		return xchrome_socket_pages["connecting"]
}

;socket error handler
xchrome_sock_error(iError, iSocket){
	;get socket page
	if !isObject(page := xchrome_sock_page(iSocket))
		return
	
	;call page handler
	page.on_error(iError, iSocket)
}

;socket event handler
xchrome_sock_event(sEvent, iSocket := 0, sName := 0, sAddr := 0, sPort := 0, ByRef bData := 0, bDataLength := 0){
	;get socket page
	if !isObject(page := xchrome_sock_page(iSocket))
		return
	
	;call page handler
	page.on_event(sEvent, iSocket, sName, sAddr, sPort, bData, bDataLength)
}

;requires
#Include *i %A_LineFile%\..\AHKsock.ahk
#Include *i %A_LineFile%\..\xget.ahk
#Include *i %A_LineFile%\..\xtrim.ahk
#Include *i %A_LineFile%\..\xalert.ahk
#Include *i %A_LineFile%\..\xconfig.ahk
#Include *i %A_LineFile%\..\xcli_esc.ahk
#Include *i %A_LineFile%\..\xjson_decode.ahk
#Include *i %A_LineFile%\..\xjson_encode.ahk
#Include *i %A_LineFile%\..\xpath_select.ahk
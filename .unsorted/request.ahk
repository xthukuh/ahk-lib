class Request {
	__url := ""
	__method := ""
	__headers := ""
	__connect_timeout := 60000
	__send_timeout := 30000
	__retrieve_timeout := 120000
	__resolve_timeout := 0
	__useragent := ""
	url {
		get {
			return this.__url
		}
		set {
			return this.__url := this.xtrim(value)
		}
	}
	method {
		get {
			return this.__method
		}
		set {
			method := this.xtrim(value)
			StringUpper, method, method
			if method not in HEAD,GET,POST,PUT,DELETE,CONNECT,OPTIONS,TRACE
				method := "GET"
			return this.__method := method
		}
	}
	headers {
		get {
			return this.__headers
		}
		set {
			headers := this.headersObject(value)
			return this.__headers := headers
		}
	}
	connect_timeout {
		get {
			return this.__timeout(this.__connect_timeout)
		}
		set {
			return this.__connect_timeout := this.__timeout(value)
		}
	}
	send_timeout {
		get {
			return this.__timeout(this.__send_timeout)
		}
		set {
			return this.__send_timeout := this.__timeout(value)
		}
	}
	retrieve_timeout {
		get {
			return this.__timeout(this.__retrieve_timeout)
		}
		set {
			return this.__retrieve_timeout := this.__timeout(value)
		}
	}
	resolve_timeout {
		get {
			return this.__timeout(this.__resolve_timeout)
		}
		set {
			return this.__resolve_timeout := this.__timeout(value)
		}
	}
	useragent {
		get {
			value := this.xtrim(this.__useragent)
			if value =
			{
				value := "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36"
				this.__useragent := value
			}
			return value
		}
		set {
			this.__useragent := this.xtrim(value)
		}
	}
	timeouts := false
	redirect := true
	data := ""
	whr := ""
	__New(url, method := "GET", data := "", headers := ""){
		this.url := url
		this.method := method
		this.headers := headers
		this.data := data
	}
	send(){
		try {
			this.whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			if this.timeouts
				this.whr.SetTimeouts(this.resolve_timeout, this.connect_timeout, this.send_timeout, this.retrieve_timeout)
			this.whr.Open(this.method, this.url, true)
			headers := this.headers
			if (!(isObject(headers) && headers.HasKey("User-Agent")))
				this.whr.SetRequestHeader("User-Agent", this.useragent)
			if (!(isObject(headers) && headers.HasKey("Content-Type") && this.method == "POST"))
				this.whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
			if (isObject(headers) && headers.Count())
			{
				for key, val in headers
					this.whr.SetRequestHeader(key, val)
			}
			if !this.redirect
				this.whr.Option(6) := false
			if this.data
				this.whr.Send(this.data)
			else this.whr.Send()
			this.whr.WaitForResponse()
			response := Object()
			response.text := this.whr.ResponseText
			response.body := this.whr.ResponseBody
			response.status := this.whr.Status
			response.headers := this.headersObject(this.whr.GetAllResponseHeaders())
			return response
		}
		catch e
		{
			_error =
			_what := this.xtrim(e.What)
			_message := this.xtrim(e.Message)
			_extra := this.xtrim(e.Extra)
			if _what !=
				_error .= " " _what
			if _message !=
				_error .= (_error != "" ? "; " : "") _message
			if _extra !=
				_error .= (_error != "" ? ";`n" : "") _extra
			_error := "Request Exception!" _error
			ErrorLevel := _error
			return false
		}
	}
	__timeout(value){
		value := value * 1
		if value < 1000
			value := 0
		return value
	}
	formParams(data, parent := ""){
		buffer =
		if isObject(data)
		{
			for key, val in data
			{
				key := this.uriencode(key)
				val := isObject(val) ? this.formParams(val, key) : this.uriencode(val)
				pair := (parent != "" ? parent "[" key "]" : key) "=" val
				buffer .= buffer != "" ? "&" pair : pair
			}
		}
		else {
			data := RegExReplace(data, "^\s*\?")
			pairs := StrSplit(data, "&")
			for i, pair in pairs
			{
				pair := this.xtrim(pair)
				if pair =
					continue
				parts := StrSplit(pair, "=")
				pair := this.uriencode(parts[1]) "=" this.uriencode(parts[2])
				buffer .= buffer != "" ? "&" pair : pair
			}
		}
		return buffer
	}
	headersObject(headers := ""){
		buffer := Object()
		if isObject(headers)
		{
			for key, val in headers
			{
				key := this.xtrim(key)
				if (!key || !val || isObject(val))
					continue
				buffer[key] := val
			}
		}
		else {
			headers := StrSplit(headers, "`n")
			for i, header in headers
			{
				header := this.xtrim(header)
				if header not contains `:
					continue
				key := SubStr(header, 1, (InStr(header, ":") -1))
				val := SubStr(header, (InStr(header, ":") +1))
				if (key && val)
					buffer[key] := val
			}
		}
		return buffer
	}
	uriencode(uri, enc:="UTF-8"){
		this.strputvar(uri, var, enc)
		f := A_FormatInteger
		SetFormat, IntegerFast, H
		loop
		{
			code := NumGet(var, A_Index - 1, "UChar")
			if !code
				break
			if (code >= 0x30 && code <= 0x39 || code >= 0x41 && code <= 0x5A || code >= 0x61 && code <= 0x7A)
				res .= Chr(code)
			else res .= "%" . SubStr(code + 0x100, -1)
		}
		SetFormat, IntegerFast, %f%
		return, res
	}
	uridecode(uri, enc:="UTF-8"){
		pos := 1
		loop
		{
			pos := RegExMatch(uri, "i)(?:%[\da-f]{2})+", code, pos ++)
			If (pos = 0)
				Break
			VarSetCapacity(var, StrLen(code) // 3, 0)
			StringTrimLeft, code, code, 1
			Loop, Parse, code, `%
				NumPut("0x" . A_LoopField, var, A_Index - 1, "UChar")
			StringReplace, uri, uri, `%%code%, % StrGet(&var, enc), all
		}
		return uri
	}
	strputvar(Str, ByRef Var, Enc = ""){
		Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
		VarSetCapacity(Var, Len, 0)
		return StrPut(Str, &Var, Enc)
	}
	xtrim(str){
		return RegExReplace(str, "^\s*|\s*$")
	}
}



xrequest(url, method := "GET", data := "", headers := "", options := ""){
	if !is_url(url)
		return xerror("Invalid xrequest url """ url """")
	method := RegExMatch(method := xtrim(method), "i)^(HEAD|GET|POST|PUT|DELETE|CONNECT|OPTIONS|TRACE)$") ? xupper(method) : "GET"
	_options := Object()
	_options.type := 1 ;0=str, 1=form, 2=json
	_options.redirect := true
	_options.timeouts := false
	_options.connect_timeout := 60000
	_options.send_timeout := 30000
	_options.retrieve_timeout := 120000
	_options.resolve_timeout := 0
	_options.useragent := "" ;Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36
	options := oreplace(options, _options)
	_headers := Object()
	_headers_track := Object()
	if (useragent := xtrim(options.useragent))
	{
		key := "User-Agent", value := useragent
		__request_header_add(key, value, _headers_track, _headers)
	}
	if !xempty(data)
	{
		if (options.type < 2)
		{
			key := "Content-Type", value := "application/x-www-form-urlencoded"
			__request_header_add(key, value, _headers_track, _headers)
			data := request_query(data)
		}
		else if (options.type == 2)
		{
			key := "Content-Type", value := "application/json"
			__request_header_add(key, value, _headers_track, _headers)
			data := IsObject(data) ? json_create(data) : xtrim(data)
		}
		data := xtrim(data)
	}
	else data =
	headers := request_headers(headers, headers_track)
	for i, _header in _headers
	{
		if isObject(header := __request_header(i, _header, headers_track))
			headers.Insert(header)
	}
	key := "", value := "", _header := "", _headers := "", _headers_track := "", headers_track := "", header := "", i := ""
	try {
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		if options.timeouts
			whr.SetTimeouts(options.resolve_timeout, options.connect_timeout, options.send_timeout, options.retrieve_timeout)
		whr.Open(method, url, true)
		if (isObject(headers) && headers.Count())
		{
			for i, header in headers
			{
				if (isObject(header) && header.HasKey("key") && header.HasKey("value"))
					whr.SetRequestHeader(header.key, header.value)
			}
		}
		if !options.redirect
			whr.Option(6) := false
		if data !=
			whr.Send(data)
		else whr.Send()
		whr.WaitForResponse()
		return new __xrequest_whr_response(whr, headers, data, options)
	}
	catch e {
		return xerror(exstr(e))
	}
}

class __xrequest_whr_response {
	whr {
		get {
			return this.__whr
		}
		set {
			return this.__whr := value
		}
	}
	ResponseBody {
		get {
			whr := this.whr
			return isObject(whr) ? whr.ResponseBody : ""
		}
	}
	body {
		get {
			return this.ResponseBody
		}
	}
	ResponseText {
		get {
			whr := this.whr
			return isObject(whr) ? whr.ResponseText : ""
		}
	}
	text {
		get {
			return this.ResponseText
		}
	}
	Status {
		get {
			whr := this.whr
			return xint(isObject(whr) ? whr.Status : 0)
		}
	}
	code {
		get {
			return this.Status
		}
	}
	request_headers {
		get {
			return IsObject(temp := this.__request_headers) ? temp : Object()
		}
		set {
			return this.__request_headers := (IsObject(value) ? value : Object())
		}
	}
	response_headers {
		get {
			whr := this.whr
			return isObject(whr) ? request_headers(whr.GetAllResponseHeaders()) : Object()
		}
	}
	headers {
		get {
			return {request: this.request_headers, response: this.response_headers}
		}
	}
	data {
		get {
			return xtrim(this.__data)
		}
		set {
			return this.__data := xtrim(value)
		}
	}
	options {
		get {
			return IsObject(temp := this.__options) ? temp : Object()
		}
		set {
			return this.__options := (IsObject(value) ? value : Object())
		}
	}
	__New(whr, request_headers, data, options){
		this.whr := whr
		this.request_headers := request_headers
		this.data := data
		this.options := options
	}
}

#Include <json_create>
#Include <xint>
#Include <xcase>
#Include <xempty>
#Include <is_url>
#Include <xtrim>
#Include <xerror>
#Include <exstr>
#Include <oreplace>
#Include <request_query>
#Include <request_headers>
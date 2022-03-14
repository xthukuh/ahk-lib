/*
	INI Config Helper
	By Martin Thuku (2021-05-19 15:40:54)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

class xconfig
{
	;ini file (default = A_ScriptDir "\A_ScriptName(no-ext).ini")
	static config_ini := ""
	
	;ini section (default = "main")
	static config_section := ""
	
	;debug callback (isFunc) - %debug_callback%(msg, _level, "xconfig")
	static debug_callback := ""

	;debug level - (levels = 0, 1) - set higher than 1 to disable debugging.
	static debug_level := 0

	;new instance
	__New(ini := "", sect := "", fn_debug := "")
	{
		this.ini := ini
		this.sect := sect
		this.fn_debug := fn_debug
		this.error := ""
	}

	;debug
	debug(msg, _level := 0)
	{
		if (_level < this.debug_level)
			return
		if _level
			this.error := msg
		if isFunc(fn := this.fn_debug)
			%fn%(msg, _level, "xconfig")
		if isFunc(fn := this.debug_callback)
			%fn%(msg, _level, "xconfig")
	}

	;get ini file path (dir initialized)
	path(ini := "")
	{
		;ini path
		if ((ini := xtrim(ini)) == "")
			ini := xtrim(this.ini)
		if ini =
			ini := xtrim(this.config_ini)
		if ini =
		{
			SplitPath, A_ScriptName,,,, _name
			ini := A_ScriptDir "\" _name ".ini"
		}
		
		;ignore invalid path (empty name)
		SplitPath, ini,, _dir, _ext, _name
		if ((_name := xtrim(_name)) == "")
			return this.debug("Config ini file is undefined!", 1)
		
		;set path
		path := _dir "\" _name
		if ((_ext := xtrim(_ext)) != "" && _ext != "ini")
			path .= "." _ext
		path .= ".ini"
		
		;initialize config dir
		IfNotExist, % path
		{
			SplitPath, path,, _dir
			IfNotExist, % _dir
			{
				FileCreateDir, % _dir
				if ErrorLevel
					return this.debug("Failed to create config dir! (" _dir ")", 1)
			}
		}

		;result - initialized path
		return path
	}

	;get ini section
	section(sect := "")
	{
		;ini section
		if ((sect := xtrim(sect)) == "")
			sect := xtrim(this.sect)
		if sect =
			sect := xtrim(this.config_section)
		
		;result - section name (default = "main")
		return sect != "" ? sect : "main"
	}

	;section data
	section_data(ini, sect)
	{
		if !isObject(this.__data)
			this.__data := Object()
		if !(this.__data.HasKey(ini) && isObject(this.__data[ini]))
			this.__data[ini] := Object()
		if !(this.__data[ini].HasKey(sect) && isObject(this.__data[ini][sect]))
			this.__data[ini][sect] := Object()
		return this.__data[ini][sect]
	}

	;setup opts
	setup(options := "", sect := "", ini := "")
	{
		xmsg(xjson_encode(options))
		;check options
		if !(isObject(options) && options.Count())
			return this.debug("Setup aborted! Invalid options.")
		
		;check ini path & section
		if (!(ini := this.path(ini)) || !(sect := this.section(sect)))
			return this.debug("Setup aborted! Invalid ini path/section. (" ini " [" sect "])", 1)

		;setup options
		data := this.section_data(ini, sect)
		for key, val in options
			data[key] := this.read(key, val, sect, ini)
		
		;result - section data
		return data
	}

	;update opts
	update(options := "", sect := "", ini := "")
	{
		;check options
		if !(isObject(options) && options.Count())
			return this.debug("Update aborted! Invalid options.")
		
		;check ini path & section
		if (!(ini := this.path(ini)) || !(sect := this.section(sect)))
			return this.debug("Update aborted! Invalid ini path/section. (" ini " [" sect "])", 1)

		;setup options
		for key, val in options
			this.save(key, val, sect, ini)
		
		;result - section data
		return this.section_data(ini, sect)
	}

	;get config data
	data(key := "", default_val := "", sect := "", ini := "")
	{
		;check ini path & section
		if (!(ini := this.path(ini)) || !(sect := this.section(sect)))
			return this.debug("Invalid data ini path/section. (" ini " [" sect "])", 1)
		
		;section data - key
		data := this.section_data(ini, sect)
		if (key := xtrim(key))
		{
			;key value
			if !data.HasKey(key)
				data[key] := this.read(key, default_val, sect, ini)
			
			;result - key value
			return data[key]
		}
		
		;result - section data
		return data
	}

	;get config bool
	data_bool(key, default_val := 0, sect := "", ini := "")
	{
		return this.data(key, default_val ? 1 : 0, sect, ini) ? 1 : 0
	}

	;get config num
	data_num(key, default_val := 0, sect := "", ini := "")
	{
		return (this.data(key, default_val * 1, sect, ini) * 1)
	}

	;ini value - encode/decode
	value(val, _encode := 0)
	{
		;ignore empty
		if ((val := xtrim(val)) == "")
			return val
		
		;result - encoded/decoded val
		return _encode ? xurl_encode(val) : xurl_decode(val)
	}

	;save value
	save(key, val, sect := "", ini := "")
	{
		;ignore invalid
		if (!(key := xtrim(key)) || !(ini := this.path(ini)) || !(sect := this.section(sect)))
			return this.debug("IniWrite aborted! Invalid ini path/section/key. (" ini " [" sect "])", 1)
		
		;ini write
		_val := this.value(val, 1)
		IniWrite, % _val, % ini, % sect, % key
		if ErrorLevel
			return this.debug("IniWrite failed! ([" sect "] " key " = " _val ")`n - " ini, 1)
		
		;section data - update key
		data := this.section_data(ini, sect)
		data[key] := val

		;success
		return 1
	}

	;read value
	read(key, default_val := "", sect := "", ini := "")
	{
		;check ini path & section
		if (!(ini := this.path(ini)) || !(sect := this.section(sect)))
			return this.debug("IniRead aborted! Invalid ini path/section. (" ini " [" sect "])", 1)
		
		;ini read
		IniRead, out, %ini%, %sect%, %key%

		;read error (set default)
		if (out = "ERROR")
		{
			this.save(key, default_val, sect, ini)
			IniRead, out, %ini%, %sect%, %key%
			if (out = "ERROR")
				return this.debug("IniRead failed! ([" sect "] " key " = " default_val ")`n - " ini, 1)
		}

		;result - read ini value
		return this.value(out)
	}

	;reset
	reset(ini := "")
	{
		;check ini path & section
		if !(ini := this.path(ini))
			return this.debug("Reset aborted! Invalid ini path. (" ini ")", 1)

		;reset config
		IfExist, % ini
		{
			;delete ini
			FileDelete, % ini
			if ErrorLevel
				return this.debug("Reset failed! Failed to delete ini file. (" ini ")", 1)
	
			;delete
			if (isObject(this.__data) && this.__data.HasKey(ini))
				this.__data.Delete(ini)
			return 1
		}
	}
}

;requires
#Include *i %A_LineFile%\..\xtrim.ahk
#Include *i %A_LineFile%\..\xurl_encode.ahk
#Include *i %A_LineFile%\..\xurl_decode.ahk
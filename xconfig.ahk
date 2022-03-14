/*
	INI Config Helper
	By Martin Thuku (2021-05-19 15:40:54)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
*/

class xconfig
{
	;static vars
	static config_ini := "" ;default = A_ScriptDir "\" A_ScriptName(no ext) ".ini"
	static config_section := "" ;default = "main"
	static debug_callback := ""
	static debug_level := 0

	;new instance
	__New(ini := "", section := "", fn_debug := "")
	{
		this.ini := ini
		this.section := section
		this.fn_debug := fn_debug
		this.config_flags := Object()
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

	;validate ini key
	is_key(key)
	{
		if ((key := xtrim(key)) != "" && RegExMatch(key, "i)^[\w]+$"))
			return key
	}

	;validate ini section
	is_section(section)
	{
		return this.is_key(section)
	}

	;validate ini file path
	is_ini(ini)
	{
		if (path := xpath(ini, _error, _path_ext := "ini"))
		{
			SplitPath, path, _basename, _dir, _ext, _name
			if (_name != "" && _ext == "ini")
				return path
		}
	}

	;get ini section
	get_section(section := "")
	{
		if (tmp := this.is_section(section))
			return tmp
		if (tmp := this.is_section(this.section))
			return tmp
		if (tmp := this.is_section(xconfig.config_section))
			return tmp

		;default section name
		return "main"
	}

	;get ini file path
	get_ini(ini := "")
	{
		if (tmp := this.is_ini(ini))
			return tmp
		if (tmp := this.is_ini(this.ini))
			return tmp
		if (tmp := this.is_ini(xconfig.config_ini))
			return tmp
		
		;default ini file path
		SplitPath, A_ScriptFullPath, _basename, _dir, _ext, _name
		return _dir "\" _name ".ini"
	}

	;key flags - this.config_flags
	key_flags(key, flags := "", section := "", ini := "")
	{
		if !(section := this.get_section(section))
			return
		if !(ini := this.get_ini(ini))
			return
		if !(key := this.is_key(key))
			return
		fkey := ini "|" section "|" key
		if StrLen(flags := xtrim(flags))
			return this.config_flags[fkey] := flags
		if this.config_flags.HasKey(fkey)
			return this.config_flags[fkey]
	}

	;ini value
	value(val, _encode := 0, flags := "")
	{
		;decode
		if (!_encode && !xis_num(val) && !isObject(val))
			val := xurl_decode(val)
		
		;apply flags
		if ((flags := xtrim(flags)) != "")
		{
			;flags = trim|number|boolean|int|abs|min:0|max:20
			loop, parse, flags, `|
			{
				flag := xtrim(A_LoopField)
				if (flag == "trim")
					val := xtrim(val)
				else if (flag == "number")
					val := xnum(val)
				else if (flag == "boolean")
					val := !!val
				else if (flag == "int")
					val := xint(val)
				else if (flag == "abs")
					val := xnum(Abs(xnum(val)))
				else if (SubStr(flag, 1, 3) = "min" && (p := InStr(flag, ":")))
				{
					val := xnum(val)
					min := xnum(SubStr(flag, p + 1))
					if (val < min)
						val := min
				}
				else if (SubStr(flag, 1, 3) = "max" && (p := InStr(flag, ":")))
				{
					val := xnum(val)
					max := xnum(SubStr(flag, p + 1))
					if (val > max)
						val := max
				}
				;todo: support more flags
			}
		}

		;encode
		if _encode
			val := xurl_encode(val)

		;result
		return val
	}

	;section value - parse
	section_value(value, section := "", ini := "")
	{
		opts := ""
		if !isObject(value)
		{
			loop, parse, value, `n
			{
				line := xtrim(A_LoopField)
				if ((p := InStr(line, "=")) && (key := this.is_key(SubStr(line, 1, p - 1))))
				{
					flags := this.key_flags(key, "", section, ini)
					val := this.value(SubStr(line, p + 1), 0, flags)
					if !isObject(opts)
						opts := Object()
					opts[key] := val
				}
			}
		}
		else {
			for key, val in value
			{
				if !(key := this.is_key(key))
					continue
				flags := this.key_flags(key, "", section, ini)
				val := this.value(val, 0, flags)
				if !isObject(opts)
					opts := Object()
				opts[key] := val
			}
		}
		return opts
	}

	;ini read
	read(key := "", default_value := "", section := "", ini := "", flags := "")
	{
		if !(section := this.get_section(section))
			return
		if !(ini := this.get_ini(ini))
			return
		if (key := this.is_key(key))
		{
			flags := this.key_flags(key, flags, section, ini)
			IniRead, out, % ini, % section, % key
			if (out = "ERROR")
			{
				this.write(default_value, key, section, ini, flags)
				return default_value
			}
			return this.value(out, 0, flags)
		}
		IniRead, out, % ini, % section
		return this.section_value(out, section, ini)
	}

	;ini write
	write(value, key := "", section := "", ini := "", flags := "")
	{
		if !(section := this.get_section(section))
			return
		if !(ini := this.get_ini(ini))
			return
		if !(key := this.is_key(key))
			return this.debug("Invalid write section key.", 1)
		IfNotExist, % ini
		{
			FileAppend,, % ini, CP0
			if ErrorLevel
				return this.debug("Error creating ini file (" ini ")", 1)
		}
		flags := flags != "" ? flags : this.key_flags(key, "", section, ini)
		val := this.value(value, 1, flags)
		IniWrite, % val, % ini, % section, % key
		if ErrorLevel
			return this.debug("Ini write failure. (val|key|section|ini = " val "|" key "|" section "|" ini ")", 1)
		return 1
	}

	/*
		setup options
		options := {
			key: default_value,
			key: [default_value, flags (see this.value)]
		}
	*/
	setup(options, section := "", ini := "")
	{
		if !isObject(options)
			return
		if !(section := this.get_section(section))
			return
		if !(ini := this.get_ini(ini))
			return
		opts := Object()
		for key, value in options
		{
			if (key := this.is_key(key))
			{
				flags := ""
				if isObject(value)
				{
					val := value[1]
					if (value.Length() >= 2)
						flags := value[2]
				}
				else val := value
				opts[key] := this.read(key, val, section, ini, flags)
			}
		}
		return opts
	}

	;save options
	save(options, section := "", ini := "")
	{
		if !isObject(options)
			return
		if !(section := this.get_section(section))
			return
		if !(ini := this.get_ini(ini))
			return
		for key, value in options
		{
			if (key := this.is_key(key))
			{
				flags := ""
				if isObject(value)
				{
					val := value[1]
					if (value.Length() >= 2)
						flags := value[2]
				}
				else val := value
				if !this.write(val, key, section, ini, flags)
					return
			}
		}
		return 1
	}
}

;requires
#Include *i %A_LineFile%\..\xnum.ahk
#Include *i %A_LineFile%\..\xtrim.ahk
#Include *i %A_LineFile%\..\xpath.ahk
#Include *i %A_LineFile%\..\xurl_encode.ahk
#Include *i %A_LineFile%\..\xurl_decode.ahk
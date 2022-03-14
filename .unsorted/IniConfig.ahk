/*
	AHK IniConfig LIBRARY
	==============================================================================
	This is an object wrapper for *.ini file manipulation
	It is meant to make reading and writing config files easy and object oriented
	By @isthuku (www.naicode.com)

	USAGE
	==============================================================================
	Instantiate providing the config file name or path and the name of sections
	If there is a critical problem, an exception is thrown
	If there is an error with an operation, ErrorLevel contains the error message
	
	Example "config.ini" contents:
	==============================================================================
	[main]
	a = 1
	[gui]
	w = 500
	
	Example usage with "config.ini":
	==============================================================================
	
	;new instance
	config := new IniConfig("config.ini", "main", "gui")
	
	;to prevent ini file from being created if it doesnt exist you can set
	config.create_if_not_exist := false
	
	;load config data
	if !config.get()
	{
		MsgBox, 0, Error, % ErrorLevel
		return
	}
	
	;add section (add value to save section to ini file)
	config.test := "key=value`nkey2=value2"
	or config.test := {key: "value", key2: "value"}
	or config.section(config, "test", "key=value`nkey2=value2")
	or config.section(config, "test", {key: "value", key2: "value"})
	
	;example remove section
	config.remove("gui")
	
	;load section
	config.main.get()
	
	;example reading
	a := config.main.a
	or a := config.main.read("a")
	if ErrorLevel
	{
		MsgBox, 0, Error, % ErrorLevel
		return
	}
	
	;example write
	config.gui.h := 600
	or config.gui.write("h", 600)
	if ErrorLevel
	{
		MsgBox, 0, Error, % ErrorLevel
		return
	}
	
	;example remove section key
	config.gui.remove("w")
	if ErrorLevel
	{
		MsgBox, 0, Error, % ErrorLevel
		return
	}
	
	;example add section key
	config.gui.h := 400
	or config.gui.write("h", 400)
	
	you can also access:
	config.__file	;config file full path
	config.__dir	;config file dir
	config.__data	;config key value object where key = section name and value = IniConfig.section object
	config.__sections	;config array of section names
	
	;you can also access section:
	config.main.__data	;config section (main) key value object for the section data
	
	==============================================================================
*/


class IniConfig {
	
	;create if not exist
	__data := Object()
	__dir := ""
	__file := ""
	__sections := []
	create_if_not_exist := true
	
	;ini instance
	__New(ini_file := "config.ini", sections*){
		
		MsgBox % ini_file " " sections.length
		
		;check ini sections
		temp := Object()
		loop, % sections.Count()
		{
			sec := RegExReplace(sections[A_Index], "^\s*|\s*$")
			if RegExMatch(sec, "^[0-9a-zA-Z_]+$")
				temp.Insert(sec)
			else this.__error("Config section name """ sec """ is invalid")
		}
		
		;check ini file
		ini_file := RegExReplace(ini_file, "^\s*|\s*$")
		if !RegExMatch(ini_file, "^[^\\\/:\*\?""<>\|]+$")
			return this.__error("Invaild config file name/path """ ini_file """")
		
		SplitPath, ini_file, fname, dir, ext, name
		ext := RegExReplace(ext, "^\s*|\s*$")
		dir := RegExReplace(dir, "^\s*|\s*$")
		name := RegExReplace(name, "^\s*|\s*$")
		fname := RegExReplace(fname, "^\s*|\s*$")
		if (name == "" || fname == "")
			return this.__error("Config file name is invalid")
		StringLower, ext, ext
		fname := (ext == "ini" ? name : fname) ".ini"
		dir := dir == "" ? A_ScriptDir : dir
		
		;set instance vars
		this.__dir := dir
		this.__file := dir "\"
		this.__sections := temp
	}
	
	;on get section value
	__Get(sec){
		sec := this.__section(sec)
		return sec ? (this.__data.HasKey(sec) ? this.__data[sec] : (this.__data[sec] := new this.section(this, sec))) : ""
	}
	
	;on set section value
	__Set(sec, value){
		sec := this.__section(sec)
		if !sec
			return this.__error("Invalid config section name", false)
		if this.__data.HasKey(sec)
			section := this.__data[sec]
		else section := (this.__data[sec] := new this.section(this, sec))
		return section.set(value)
	}
	
	;normalize section name
	__section(sec){
		sec := RegExReplace(sec, "^\s*|\s*$")
		if RegExMatch(sec, "^\[(.*)\]$")
			sec := RegExReplace(sec, "^\[(.*)\]$", "$1")
		sec := RegExReplace(sec, "^\s*|\s*$")
		return sec
	}
	
	;error handler
	__error(msg, throwable := true){
		if throwable
			throw msg
		else ErrorLevel := msg
	}
	
	;init sections
	get(){
		;init sections
		sections := this.__sections, count := sections.Count()
		if !count
			return this.__error("Config sections not provided", false)
	
		;load sections
		this.__data := Object()
		loop, % count
		{
			sec := sections[A_Index]
			if !sec
				return this.__error("Invalid config section name at index " A_Index, false)
			section := (this.__data[sec] := new this.section(this, sec))
			if !section.get()
				return this.__error("Config section parse error at index " A_Index " " ErrorLevel, false)
		}
		
		;return self
		return this
	}
	
	;delete section
	remove(sec){
		sec := this.__section(sec)
		if !sec
			return this.__error("Invalid config section name", false)
		
		;validate ini file path
		file := this.__file
		if !((fx := FileExist(file)) && !InStr(fx, "D"))
			return this.__error("Config file does not exist", false)
		
		;delete ini section
		IniDelete, %file%, %sec%
		if ErrorLevel
			return this.parent.__error("Config delete error! Failed to delete [" sec "]", false)
		
		;remove section from data
		this.__data.Delete(sec)
		
		;remove section from sections
		loop, % this.__sections.Count()
		{
			if (this.__sections[A_Index] == sec)
			{
				this.__sections.RemoveAt(A_Index)
				break
			}
		}
		
		;return self
		return this
	}
	
	;section object class
	class section {
		__parent := ""
		__name := ""
		__data := Object()
		
		;ini section instance
		__New(self, name){
			this.__parent := &self
			this.__name := name
			if this.parent.__data.HasKey(name)
				this.parent.__data[name] := this
		}
		
		;on get key value
		__Get(key){
			key := RegExReplace(key, "^\s*|\s*$")
			if !RegExMatch(key, "^[^;=]+$")
				return this.parent.__error("Invalid config section key """ key """", false)
			if this.__data.HasKey(key)
				return this.__data[key]
			return this.read(key)
		}
		
		;on set key value
		__Set(key, val){
			key := RegExReplace(key, "^\s*|\s*$")
			if !RegExMatch(key, "^[^;=]+$")
				return this.parent.__error("Invalid config section key """ key """", false)
			val := RegExReplace(val, "^\s*|\s*$")
			return this.write(key, val)
		}
		
		;normalize value
		__value(value, write := true, default := ""){
			if write
			{
				if IsObject(value)
					value := "[Object]"
				else if (value === true)
					value := "true"
				else if (value === false)
					value := "false"
				value := RegExReplace(value, "^\s*|\s*$")
			}
			else {
				value := RegExReplace(value, "^\s*|\s*$")
				StringLower, value_lower, value
				if (value_lower == "error")
					value := default
				else if (value_lower == "false")
					value := false
				else if (value_lower == "true")
					value := true
				else if value is number
					value := value * 1
			}
			return value
		}
		
		;get parent class
		parent {
			get {
				if (NumGet(this.__parent) == NumGet(&this))
					return Object(this.__parent)
			}
		}
		
		;set section key object value
		set(value){
			ErrorLevel := ""
			
			;set value to object
			if !isObject(value)
			{
				temp := Object()
				value := RegExReplace(value, "^\s*|\s*$")
				loop, parse, value, `n
				{
					key_val := RegExReplace(A_LoopField, "^\s*|\s*$")
					p := InStr(key_val, "=")
					key := RegExReplace(SubStr(key_val, 1, p - 1),  "^\s*|\s*$")
					val := RegExReplace(SubStr(key_val, p + 1),  "^\s*|\s*$")
					temp[key] := val
				}
				value := temp
				temp =
			}
			
			;set value
			if isObject(value)
			{
				for key, val in value
				{
					if (!this.write(key, val) && ErrorLevel)
						return this.parent.__error("Config section [" this.__name "] > " key " = " val " set error: " ErrorLevel, false)
				}
			}
			
			;return self
			return this
		}
		
		;get section key values
		get(){
			ErrorLevel := ""
			
			;validate section
			section := RegExReplace(this.__name, "^\s*|\s*$")
			if !section
				return this.parent.__error("Invalid config section name", false)
			
			;validate ini file path
			file := this.parent.__file
			if !((fx := FileExist(file)) && !InStr(fx, "D"))
				return this.parent.__error("Config file does not exist", false)
			
			;read section
			IniRead, values, %file%, %section%
			data := Object()
			values := RegExReplace(values, "^\s*|\s*$")
			if values !=
			{
				loop, parse, values, `n
				{
					key_val := RegExReplace(A_LoopField, "^\s*|\s*$")
					key := SubStr(key_val, 1, InStr(key_val, "=") - 1)
					key := RegExReplace(key, "^\s*|\s*$")
					if (key && !this.read(key) && ErrorLevel)
						return this.parent.__error("Config section [" section "] parse error: " ErrorLevel, false)
				}
			}
			
			;return self
			return this
		}
		
		;read section key
		read(key, default := ""){
			ErrorLevel := ""
			
			;validate key
			key := RegExReplace(key, "^\s*|\s*$")
			if !RegExMatch(key, "^[^;=]+$")
				return this.parent.__error("Invalid config section key """ key """", false)
			
			;validate section
			section := RegExReplace(this.__name, "^\s*|\s*$")
			if !section
				return this.parent.__error("Invalid config section name", false)
			
			;validate ini file path
			file := this.parent.__file
			if !((fx := FileExist(file)) && !InStr(fx, "D"))
				return this.parent.__error("Config file does not exist", false)
			
			;read ini file key
			IniRead, result, %file%, %section%, %key%
			result := this.__value(result, false, default)
			
			;set & return key value
			return (this.__data[key] := result)
		}
		
		;write section key
		write(key, value){
			ErrorLevel := ""
			
			;validate key
			key := RegExReplace(key, "^\s*|\s*$")
			if !RegExMatch(key, "^[^;=]+$")
				return this.parent.__error("Invalid config section key """ key """", false)
			
			;validate section
			section := RegExReplace(this.__name, "^\s*|\s*$")
			if !section
				return this.parent.__error("Invalid config section name", false)
			
			;trim/fix value
			value := this.__value(value)
			
			;validate ini file path
			file := this.parent.__file
			if !((fx := FileExist(file)) && !InStr(fx, "D"))
			{
				if !this.parent.create_if_not_exist
					return this.parent.__error("Config file does not exist", false)
				FileAppend, [%section%]`n, %file%
				if ErrorLevel
					return this.parent.__error("Config write error! Failed to create config file """ file """", false)
				ErrorLevel := ""
			}
			IniWrite, %value%, %file%, %section%, %key%
			if ErrorLevel
				return this.parent.__error("Config write error! Failed to write [" section "] > " key "=" value, false)
			
			;set key value
			return (this.__data[key] := value)
		}
		
		;remove section key
		remove(key){
			ErrorLevel := ""
			
			;validate key
			key := RegExReplace(key, "^\s*|\s*$")
			if !RegExMatch(key, "^[^;=]+$")
				return this.parent.__error("Invalid config section key """ key """", false)
			
			;validate section
			section := RegExReplace(this.__name, "^\s*|\s*$")
			if !section
				return this.parent.__error("Invalid config section name", false)
			
			;validate ini file path
			file := this.parent.__file
			if !((fx := FileExist(file)) && !InStr(fx, "D"))
				return this.parent.__error("Config file does not exist", false)
			
			;delete ini section key
			IniDelete, %file%, %section%, %key%
			if ErrorLevel
				return this.parent.__error("Config delete error! Failed to delete [" section "] > " key, false)
			
			;remove key from data
			this.__data.Delete(key)
			
			;return self
			return this
		}
	}
}
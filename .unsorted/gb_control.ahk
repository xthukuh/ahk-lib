#Include <xhead>
class gb_control_options {
	__New(options){
		
	}
}

class gb_control extends class_config {
	__is_type(type){
		static _types := ""
		if (type := xtrim(type)) =
			return
		if !isObject(_types)
		{
			types := "Text,Edit,UpDown,Picture,Button,Checkbox,Radio,DropDownList,ComboBox,"
			.= "ListBox,ListView,TreeView,Link,Hotkey,DateTime,MonthCal,Slider,Progress,"
			.= "GroupBox,Tab3,StatusBar,ActiveX,Custom"
			_types := Object()
			loop, parse, types, `,
			{
				if (_type := xtrim(A_LoopField)) !=
					_types[_type] := _type
			}
		}
		return _types.HasKey(type)
	}
	__config_default := {type: ""
		, options: ""
		, text: ""
		, name: ""
		, handler: ""}
	is_type(type){
		return gb_control.__is_type(type)
	}
	type {
		get {
			if (type := xtrim(this.config.type)) !=
			{
				if !this.is_type(type)
					xthrow("Invalid control type """ value """")
			}
			return type
		}
		set {
			if (value := xtrim(value)) !=
			{
				if !this.is_type(value)
					xthrow("Invalid control type """ value """")
			}
			return this.config.type := value
		}
	}
	options {
		get {
			return xtrim(this.config.options)
		}
		set {
			if isObject(value)
			{
				temp =
				for key, val in value
				{
					if ((val := xtrim(val)) == "" || !RegExMatch(val, "i)^[a-z0-9 ]+$"))
						continue
				}
				key := Format("{:L}", xtrim(key)), opt := ""
				if key is integer
					opt := val
				else if key = disabled
					opt := !!val ? "Disabled"
			}
		}
	}
	text := ""
	name := ""
	handler := ""
	
	__New(_type, _options := "", _text := "", _name := "", _handler := ""){
		
		type := xtrim(_type)
		options := xtrim(_options)
		text := xtrim(_text)
		name := xtrim(_name)
		handler := xtrim(_handler)
		
		if type =
			xthrow("Unspecified control type")
		if !RegExMatch(_type, "i)(" StrReplace(this.types, ",", "|") ")")
			xthrow("Unsupported control type """ type """")
		if name !=
		{
			if !RegExMatch(name, "i)[a-z0-9_]+")
				xthrow("Invalid control name """ name """")
			if options !=
				options := RegExReplace(options, "i)\s*v[a-z0-9_%]+")
			options .= " v" name
		}
		if handler !=
		{
			if options !=
				options := RegExReplace(options, "i)\s*g[a-z0-9_%]+")
		}
		
		this.type := type
		this.options := options
		this.text := text
		this.name := name
		this.handler := handler
	}
	
	options(_options := ""){
		if isObject(_options)
		{
			for key, val in _options
			{
				
			}
		}
	}
	item(){
	}
	text(){}
}


#Include <class_config>
#Include <xtrim>
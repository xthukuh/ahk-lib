class sget {
	__Call(name := "", args*){
		if RegExMatch(name, "Oi)^(set|get)([a-z0-9_]+)", matches)
		{
			prop := Format("{:L}", ltrim(trim(matches[2], " `t`r`n"), "_"))
			if !this.HasKey(prop)
				return
			sget := Format("{:L}", trim(matches[1], " `t`r`n"))
			if (sget == "get")
				return this[prop]
			value := isObject(args) && args.Length() ? args[1] : ""
			return this[prop] := value
		}
		;else if (isFunc(this.__Class "." name))
		_xmsg("Call " name " args = " xjson(args))
		if (isFunc(this.__Class "." name))
			return this[name](args*)
	}
}
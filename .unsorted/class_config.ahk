;adds config to your class by extending it
class class_config {
	__config := {}
	__config_default := {}
	_config_default(){
		if !(isObject(this.__config_default) && this.__config_default.Count())
			return Object()
		temp := Object()
		for key, val in this.__config_default
			temp[key] := val
		return temp
	}
	_config(key := "", args*){
		if !(isObject(this.__config) && ((_default := this._config_default()).Count() ? this.__config.Count() : 1))
			this.__config := _default
		if (key := trim(key, " `t`r`n"))
		{
			if args.Count()
				return this.__config[key] := args[1]
			return this.__config[key]
		}
		if args.Count()
			return this.__config := (IsObject(value := args[1]) ? value : this._config_default())
		return this.__config
	}
	config {
		get {
			return this._config()
		}
		set {
			return this._config("", value)
		}
	}
}
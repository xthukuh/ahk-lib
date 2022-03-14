;includes
#Include *i %A_LineFile%\..\..\xtrim.ahk

;xgui helper - class
class xgui_helper_cls
{
	;statics
	static _instances := {}

	;get static class
	class(ByRef name := "")
	{
		_name := this.__class
		_class := %_name%
		return _class
	}

	;get static class name
	class_name()
	{
		return this.class().__class
	}

	;validate instance
	is_instance(val, throwable := false)
	{
		class_name := this.class_name()
		if (isObject(val) && val.__class == class_name)
			return val
		if throwable
			throw "Error: value is not an instance of " class_name "."
	}

	;instances
	instances()
	{
		if isObject(instances := this.class(class_name)._instances)
			return instances
		throw "Error: " class_name "._instances is not an object."
	}

	;unset instance
	unset_instance(name)
	{
		if ((name := xtrim(name)) && (instances := this.instances()) && instances.HasKey(name))
		{
			instances.Delete(name)
			return 1
		}
	}

	;get instance
	get_instance(val)
	{
		;val > xgui instance
		if this.is_instance(val)
			return val
		
		;get instance
		if (instances := this.instances())
		{
			;val search
			if (!isObject(val) && (val := xtrim(val)) != "")
			{
				;val > name
				if (instances.HasKey(val) && this.is_instance(instance := instances[val]))
					return instance
				
				;val > id (HWND)
				for name, instance in instances
				{
					if (this.is_instance(instance) && instance.id(0) == val)
						return instance
				}
			}
		}
	}

	;new instance
	new_instance(name := "", prepend := "")
	{
		_tmp := name
		instances := this.instances()
		if ((name := xtrim(name)) != "" && instances.HasKey(name))
			throw "Error: The " this.class_name() " instance name """ name """ is already in use."
		else if (name == "")
		{
			;n := instances.Count() + 1
			n := 1
			name := prepend n
			while (instances.HasKey(name))
			{
				n += 1
				name := prepend n
			}
		}
		;xmsg("new_instance: name = [" _tmp "|" name "]")
		instances[name] := this
		this._name := name
		return name
	}

	;get instance name
	name()
	{
		if ((name := xtrim(this._name)) == "")
			throw "Error: Undefined " this.class_name() " instance name."
		return name
	}

	;set instance id << self
	set_id(id)
	{
		this._id := (id := Abs(id)) >= 1 ? id : ""
		return this
	}

	;get instance id
	id(throwable := true)
	{
		if ((id := Abs(this._id)) >= 1)
			return id
		if throwable
			throw "Error: Undefined " this.class_name() " instance ID."
	}

	;set callback << self
	set_callback(key, callback := "", _multiple := 0)
	{
		if ((key := xtrim(key)) == "")
			return this
		is_callback := isFunc(callback) || isObject(callback)
		if !isObject(this._callbacks)
			this._callbacks := {}
		if (!isObject(this._callbacks[key]) || !_multiple || !is_callback)
			this._callbacks[key] := []
		if is_callback
			this._callbacks[key].Push(callback)
		return this
	}

	;callback
	callback(key, args*)
	{
		result := ""
		if ((key := xtrim(key)) != ""
			&& isObject(this._callbacks)
			&& this._callbacks.HasKey(key)
			&& isObject(callbacks := this._callbacks[key])
			&& (len := callbacks.Length()))
		{
			loop, % len
			{
				callback := callbacks[A_Index]
				if (isFunc(callback) || isObject(callback))
				{
					if (result := %callback%(args*))
						break
				}
			}
		}
		return result
	}
}
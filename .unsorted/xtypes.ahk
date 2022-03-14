xtype(var){
	if isObject(var)
	{
		if (cls := xtrim(var.__Class))
			type := "object class::" cls
		if is_array(var)
			type := "array"
		type := "object"
	}
	else if var is integer
		type := "int"
	else if var is float
		type := "float"
	else if var is xdigit
		type := "xdigit"
	else type := "string"
	return type
}
is_type(var, type){
	type := xtrim(type)
	vtype := xtype(var)
	if (type = vtype)
		return true
	else if isObject(var)
		return false
	else if var is %type% ;integer,float,number,digit,xdigit,alpha,upper,lower,alnum,space,time
		return true
	return false
}
is_int(ByRef value){
	if value is integer
	{
		value := value * 1
		return true
	}
	return false
}
is_float(ByRef value){
	if value is float
	{
		value := xnum(value * 1)
		return true
	}
	return false
}
is_num(var, byref num := 0){
	if ((temp := xnum(var, false)) != false)
	{
		num := temp
		return true
	}
	num := 0
	return false
}

#Include <is_array>
#Include <xbuffer>
#Include <xnum>
#Include <xtrim>
;validate class object
xis_class(val, class_name){
	return isObject(val)
		&& (class_name := Trim(class_name, " `t`r`n")) != ""
		&& val.__class == class_name
}
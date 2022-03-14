is_array(var){
	return isObject(var) && (var.SetCapacity(0) = (var.MaxIndex() - var.MinIndex() + 1))
}
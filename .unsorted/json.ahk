;json operations
JSON2Object(json){
	return json_parse(json)
}
Object2JSON(obj){
	return json_create(obj)
}

#Include <json_create>
#Include <json_parse>
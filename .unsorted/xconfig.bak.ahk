;script settings
class xconfig {
	__info := ""
	__New(name := "", default := "", folder := ""){
		if name !=
			this.setName(name)
		if IsObject(default)
			this.setDefault(default)
		if folder !=
			this.setFolder(folder)
		this.load()
	}
	info(){
		if !IsObject(this.__info)
			this.__info := {pass: "xconfig", name: A_ScriptDir, default: "", folder: A_MyDocuments "\XConfig", path: "", data: ""}
		return this.__info
	}
	setName(name){
		this.info().name := xtrim(name)
		return this
	}
	setDefault(default){
		this.info().default := IsObject(default) ? default : Object()
		return this
	}
	setFolder(folder){
		this.info().folder := xtrim(folder)
		return this
	}
	name(){
		if !is_fname(name := xtrim(this.info().name))
			throw "Invalid xconfig name!"
		return name
	}
	default(){
		default := IsObject(default := this.info().default) ? default : Object()
		return default
	}
	folder(){
		folder := xtrim(this.info().folder)
		if !(dir := xdir(folder, false))
			throw "Invalid xconfig folder! """ folder """"
		return dir
	}
	path(){
		if !(path := xtrim(this.info().path))
		{
			path := this.folder() "\" this.name() ".xc"
			this.info().path := path
		}
		return path
	}
	data(){
		if xempty(this.info().data)
			this.info().data := this.default()
		return this.info().data
	}
	load(){
		data := this.data()
		if !is_file(path := this.path())
			return data
		FileRead, xcr_json, % path
		if ErrorLevel
			xthrow("Unable to read xconfig file """ path """")
		json := xcr(xcr_json, this.info().pass, false)
		temp := json_parse(json), unset(xcr_json)
		if isObject(temp)
		{
			for key, val in temp
				data[key] := val
		}
		this.info().data := temp
		unset(temp), unset(json)
		return this
	}
	save(){
		data := this.data()
		if is_file(path := this.path())
			file_delete(path)
		if !(path := xfile(path))
			xthrow(ErrorLevel)
		json := json_create(data)
		xcr_json := xcr(json, this.info().pass)
		FileAppend, %xcr_json%, % path
		if ErrorLevel
			xthrow("Unable to save xconfig file """ path """")
		return this
	}
	set(data){
		temp := this.data()
		temp := oreplace(temp, data)
		this.info().data := temp
		this.save()
	}
}

#Include <xfiles>
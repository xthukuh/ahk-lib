;includes
#Include *i %A_LineFile%\..\xtrim.ahk

;script helper
class xscript
{
	;statics
	static _vstatic_options := {}

	;static class
	_static
	{
		get {
			return xscript
		}
		set {
			return this._static
		}
	}

	;static options
	_static_options
	{
		get {
			if !isObject(this._static._vstatic_options)
				this._static._vstatic_options := {}
			return this._static._vstatic_options
		}
		set {
			return this._static_options
		}
	}

	;file info
	file
	{
		get {
			path := A_ScriptFullPath
			SplitPath, path, _basename, _dir, _ext, _name, _drive
			return {path: path
				, basename: _basename
				, dir: _dir
				, ext: _ext != "" ? Format("{:L}", _ext) : ""
				, name: _name
				, drive: _drive
				, drive_l: _drive != "" ? Format("{:U}", StrReplace(_drive, ":")) : ""}
		}
		set {
			return this.file
		}
	}

	;title
	title
	{
		get {
			return this._static_options.title
		}
		set {
			return this._static_options.title := xtrim(value)
		}
	}

	;title1 - title|file.name
	title1
	{
		get {
			if ((title := xtrim(this.title)) == "")
				title := this.file.name
			return title
		}
		set {
			this.title := value
			return this.title1
		}
	}

	;title2 - title|file.basename
	title2
	{
		get {
			if ((title := xtrim(this.title)) == "")
				title := this.file.basename
			return title
		}
		set {
			this.title := value
			return this.title2
		}
	}

	;username
	username
	{
		get {
			return Format("{:T}", A_UserName)
		}
		set {
			return this.username
		}
	}
}
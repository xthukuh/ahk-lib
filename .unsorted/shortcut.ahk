;script startup shortcut
startup_shortcut(options := ""){
	if !isObject(options)
		options := Object()
	if !options.HasKey("folder")
		options.folder := A_Startup
	if !options.HasKey("Description")
		options.Description := "Startup shortcut for " A_ScriptName
	if !A_IsCompiled
	{
		Args := options.HasKey("Args") ? xtrim(options.Args) : ""
		Args := """" A_ScriptFullPath """" (Args != "" ? " " Args : "")
		options.Args := Args
		target := A_AhkPath
	}
	else target := A_ScriptFullPath
	return create_shortcut(target, options)
}

;create shortcut
create_shortcut(target, options := ""){
	try {
		_temp_options := {folder: A_ScriptDir, overwrite: true, WorkingDir: A_ScriptDir, Args: "", Description: "", IconFile: "", ShortcutKey: "", IconNumber: "", RunState: 1}
		if !isObject(options)
			options := Object()
		for key, val in _temp_options
			if (!options.HasKey(key) || val && xtrim(options[key]) == "")
				options[key] := val
		if !(path := xtrim(target))
			throw "Shortcut target path """ target """ is invalid"
		Args := options.HasKey("Args") ? xtrim(options.Args) : ""
		name := ext := ""
		if (target == A_AhkPath)
		{
			script =
			loop, parse, Args, CSV
			{
				script := RegExReplace(xtrim(A_LoopField), "^""([^""]+)""$", "$1")
				break
			}
			if script !=
			{
				SplitPath, script,,, _ext, _name
				_name := xtrim(_name)
				if ((_ext := xlower(xtrim(_ext))) == "ahk")
					name := _name, ext := _ext
			}
		}
		if name =
			SplitPath, path,,, ext, name
		if !(name := xtrim(name))
			throw "Shortcut target path """ path """ is invalid"
		ext := xlower(xtrim(ext))
		link := name (ext && ext != "exe" ? "." ext : "") ".lnk"
		folder := options.HasKey("folder") ? xtrim(options.folder) : ""
		if !is_dir(folder)
			throw "Shortcut folder path """ folder """ does not exist or is an invalid folder"
		target := path
		shortcut := folder "\" link
		IfExist, % shortcut
		{
			FileGetShortcut, %shortcut%, shortcut_target
			overwrite := options.HasKey("overwrite") && options.overwrite
			if (shortcut_target != target && overwrite)
				FileDelete, % shortcut
		}
		IfNotExist, % shortcut
		{
			WorkingDir := options.HasKey("WorkingDir") ? xtrim(options.WorkingDir) : ""
			if (WorkingDir != "" && !is_dir(WorkingDir))
				throw "Shortcut WorkingDir path """ WorkingDir """ does not exist or is an invalid folder"
			Description := options.HasKey("Description") ? xtrim(options.Description) : ""
			ixt := "", IconFile := options.HasKey("IconFile") ? xtrim(options.IconFile) : ""
			if IconFile !=
			{
				SplitPath, IconFile,,, ixt
				if !xin(ixt := xlower(ixt), "ico,exe,dll")
					throw "Shortcut IconFile ext """ ixt """ is not supported (supported: ico,exe,dll)"
			}
			ShortcutKey := options.HasKey("ShortcutKey") ? xtrim(options.ShortcutKey) : ""
			IconNumber := xin(ixt, "exe,dll") ? (options.HasKey("IconNumber") ? xint(options.IconNumber, "") : "") : ""
			RunState := options.HasKey("RunState") ? xtrim(options.RunState) : ""
			if (RunState != "" && !xin(RunState, "1,3,5"))
				throw "Shortcut RunState value """ RunState """ is not supported (supported: 1,3,4)"
			FileCreateShortcut, %target%, %shortcut%, %WorkingDir%, %Args%, %Description%, %IconFile%, %ShortcutKey%, %IconNumber%, %RunState%
			if !is_file(shortcut)
				throw "Failed to create shortcut: " shortcut
		}
		return shortcut
	}
	catch e
	{
		error := IsObject(e) ? trim(trim(e.What) " " trim(e.Message)) : e
		ErrorLevel := error
		return false
	}
}

#Include <xfuncs>

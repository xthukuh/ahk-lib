ie_fix(version := 0, _exec := ""){
	static key := "Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
	static versions := {7:7000, 8:8888, 9:9999, 10:10001, 11:11001}
	if versions.HasKey(version)
		version := versions[version]
	if !_exec
	{
		if A_IsCompiled
			_exec := A_ScriptName
		else
			SplitPath, A_AhkPath, _exec
	}
	RegRead, _prev, HKCU, %key%, %_exec%
	if (version = "")
		RegDelete, HKCU, %key%, %_exec%
	else
		RegWrite, REG_DWORD, HKCU, %key%, %_exec%, %version%
	return _prev
}
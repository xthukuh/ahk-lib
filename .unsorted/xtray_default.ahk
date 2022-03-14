Menu, Tray, DeleteAll
Menu, Tray, NoStandard
Menu, Tray, NoDefault
if (TrayIcon := trim(TrayIcon, " `t`r`n"))
	Menu, Tray, Icon, %TrayIcon%
TrayHint := (TrayHint := trim(TrayHint, " `t`r`n")) ? TrayHint : A_ScriptName
Menu, Tray, Tip, %TrayHint%
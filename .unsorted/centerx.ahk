;get the center (screen x) of the active monitor
;provide a width and get an x to center that width
CenterX(width := 0){
	CoordMode, Mouse, Screen
	MouseGetPos, MX, MY
	SysGet, MonitorsCount, MonitorCount
	loop, % MonitorsCount
	{
		SysGet, MonitorVars_, Monitor, %A_Index%
		monitorX := MonitorVars_Left
		MonitorW := MonitorVars_Right - MonitorVars_Left
		MonitorH := MonitorVars_Bottom - MonitorVars_Top
		if (MX <= MonitorVars_Right AND MX >= monitorX){
			width := abs(width)
			return Round(MonitorX + ((monitorW / 2) - (width ? (width / 2) : 0)))
		}
	}
}
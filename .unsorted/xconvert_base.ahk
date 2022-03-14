/*
	https://www.autohotkey.com/boards/viewtopic.php?t=3925
	ConvertBase(10, 16, 119)        ; Dec to Hex: 77
	ConvertBase(16, 10, 77)         ; Hex to Dec: 119
*/
xconvert_base(InputBase, OutputBase, nptr) ;Base 2 - 36
{
    static u := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
    static v := A_IsUnicode ? "_i64tow"    : "_i64toa"
    VarSetCapacity(s, 66, 0)
    value := DllCall("msvcrt.dll\" u, "Str", nptr, "UInt", 0, "UInt", InputBase, "CDECL Int64")
    DllCall("msvcrt.dll\" v, "Int64", value, "Str", s, "UInt", OutputBase, "CDECL")
    return s
}
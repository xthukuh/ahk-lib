Base64_Encode(ByRef Out, ByRef In, InLen)
{
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", 0x40000001, "Ptr", 0, "UInt*", OutLen)
	VarSetCapacity(Out, OutLen * (1+A_IsUnicode))
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", 0x40000001, "Str", Out, "UInt*", OutLen)
	return OutLen
}

Base64_Decode(ByRef Out, ByRef In)
{
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", 0x1, "Ptr", 0, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	VarSetCapacity(Out, OutLen)
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", 0x1, "Str", Out, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	return OutLen
}
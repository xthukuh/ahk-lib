FormatHexNumber(_value, _digitNb)
{
	local hex, intFormat

	; Save original integer format
	intFormat = %A_FormatInteger%
	; For converting bytes to hex
	SetFormat Integer, Hex

	hex := _value + (1 << 4 * _digitNb)
	StringRight hex, hex, _digitNb
	; I prefer my hex numbers to be in upper case
	StringUpper hex, hex

	; Restore original integer format
	SetFormat Integer, %intFormat%

	Return hex
}

/*
// For debugging, return formatted hex string separating DWORDs
// Idem to Bin2Hex, usable directly in a MsgBox...
// Extended mode: give offsets and Ascii dump.
*/
DumpDWORDs(ByRef @bin, _byteNb, _bExtended=false)
{
	local dataSize, dataAddress, granted, line, dump, hex, ascii
	local dumpWidth, offsetSize, resultSize

	offsetSize = 4	; 4 hex digits (enough for most dumps)
	dumpWidth = 32
	dataAddress := &@bin
	; Make enough room (faster)
	resultSize := _byteNb * 4
	If _bExtended
	{
		dumpWidth = 16 ; Make room for offset and Ascii
		resultSize += offsetSize + 8 + dumpWidth
	}
	granted := VarSetCapacity(dump, resultSize)
	if (granted < resultSize)
	{
		; Cannot allocate enough memory
		ErrorLevel = Mem=%granted%
		Return -1
	}
	If _bExtended
	{
		offset = 0
		line := FormatHexNumber(offset, offsetSize) ": "
	}
	Loop %_byteNb%
	{
		; Get byte in hexa
		hex := FormatHexNumber(*dataAddress, 2)
		If _bExtended
		{
			; Get byte in Ascii
			If (*dataAddress >= 32)	; Not a control char
			{
				ascii := ascii Chr(*dataAddress)
			}
			Else
			{
				ascii := ascii "."
			}
			offset++
		}
		line := line hex A_Space
		If (Mod(A_Index, dumpWidth) = 0)
		{
			; Max dumpWidth bytes per line
			If (_bExtended)
			{
				; Show Ascii dump
				line := line " - " ascii
				ascii =
			}
			dump := dump line "`n"
			line =
			If (_bExtended && A_Index < _byteNb)
			{
				line := FormatHexNumber(offset, offsetSize) ": "
			}
		}
		Else If (Mod(A_Index, 4) = 0)
		{
			; Separate bytes per groups of 4, for readability
			line := line "| "
		}
		dataAddress++	; Next byte
	}
	If (Mod(_byteNb, dumpWidth) != 0)
	{
		If (_bExtended)
		{
			line := line " - " ascii
		}
		dump := dump line "`n"
	}

	Return dump
}
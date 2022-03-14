;hex binary string
xhex_bin(hex, _split := 0){
	hex := Trim(hex, " `n`t")
	buf =
	loop, parse, hex
	{
		char := Trim(A_LoopField, " `n`t")
		if char = 0
			buf .= "0000"
		else if char = 1
			buf .= "0001"
		else if char = 2
			buf .= "0010"
		else if char = 3
			buf .= "0011"
		else if char = 4
			buf .= "0100"
		else if char = 5
			buf .= "0101"
		else if char = 6
			buf .= "0110"
		else if char = 7
			buf .= "0111"
		else if char = 8
			buf .= "1000"
		else if char = 9
			buf .= "1001"
		else if char = A
			buf .= "1010"
		else if char = B
			buf .= "1011"
		else if char = C
			buf .= "1100"
		else if char = D
			buf .= "1101"
		else if char = E
			buf .= "1110"
		else if char = F
			buf .= "1111"
	}
	if (_split := Abs(_split * 1)) >= 1
		buf := xstr_split_b(buf, _split)
	return buf
}

;requires
#Include *i %A_LineFile%\..\xstr_split.ahk
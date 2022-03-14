;loopback offset
xoffset(index, max, _zero := false){
	offset := Mod(index := floor(xnum(index, 0) * 1), max := floor(xnum(max, 0) * 1))
	offset := index < 0 ? (!offset ? 1 : (offset + max + 1)) : (index && !offset ? max : offset)
	return offset == 0 && !_zero ? 1 : offset
}

#Include <xnum>
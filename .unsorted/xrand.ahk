xrand(min := 0, max := 100){
	min := xint(min)
	max := xint(max)
	Random, rand, %min%, %max%
	return rand
}

#Include <xint>
pxrgb(px_rgb){
	vblue := (px_rgb & 0xFF)
	vgreen := ((px_rgb & 0xFF00) >> 8)
	vred := ((px_rgb & 0xFF0000) >> 16)
	return {r: vred, g: vgreen, b: vblue}
}
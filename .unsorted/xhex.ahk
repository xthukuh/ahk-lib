xhex(str){
    loop, parse, str
        hex .= Format("{:x}", Asc(A_LoopField))
    return hex
}
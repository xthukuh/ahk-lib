link_title(url){
	if !(response := xrequest(url))
		return
	html := response.text
	html := RegExReplace(html, "\s+", " ")
	pattern := "Oi)\<title\>(.*?(?=\<\/title\>))"
	title := RegExMatch(html, pattern, matches) ? matches[1] : ""
	if title contains `%
		title := urldecode(title)
	if RegExMatch(title, "O)&#?([0-9]+);")
	{
		loop {
			if RegExMatch(title, "O)&#?([0-9]+);", matches)
				title := StrReplace(title, matches[0], Chr(matches[1]))
			else break
		}
	}
	return title
}

#Include <xrequest>
#Include <urldecode>
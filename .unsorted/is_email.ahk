;(https://emailregex.com/
is_email(ByRef email){
	if !(email := trim(email, " `t`r`n"))
		return false
	regex = ^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$
	if !RegExMatch(email, regex)
		return false
	StringLower, email, email
	return true
}
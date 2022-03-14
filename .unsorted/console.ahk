class console
{
	;current timestamp ;2021-05-16 11:53:10
	__now()
	{
		FormatTime, now, %A_Now%, yyyy-MM-dd HH:mm:ss
		return now
	}

	;args to log string
	__log_str(args*)
	{
		buf := ""
		for i, item in args
		{
			if ((item := Trim(item, " `n`t")) != "")
				buf .= (buf != "" ? "`n" : "") item
		}
		return buf
	}

	;do log
	__do_log(type := "debug", time := "", args*)
	{
		;log timestamp
		if (time == "")
			time := this.__now()
		else if (time == "0")
			time =
		
		;log type
		if (type == "")
			type := "debug"
		else if (type == "0")
			type =
		
		;log string
		if !(str := this.__log_str(args*))
			return
		
		;log

	}

	;log
	log(args*)
	{
		this.__do_log(,, args*)
	}
}
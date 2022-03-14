class interval {
	count {
		get {
			val := this.__count
			if val is not integer
				val := 0
			return val
		}
		set {
			if value is not integer
				value := 0
			return this.__count := value 
		}
	}
	timeout {
		get {
			val := this.__timeout
			if val is not integer
				val := 0
			return val
		}
		set {
			if value is not integer
				value := 0
			return this.__timeout := value 
		}
	}
	priority {
		get {
			val := this.__priority
			if val is not Integer
				val := ""
			return val
		}
		set {
			if value is not integer
				value := ""
			return this.__priority := value 
		}
	}
	args {
		get {
			return IsObject(_args := this.__args) ? _args : (this.__args := [])
		}
		set {
			return this.__args := isObject(value) ? value : []
		}
	}
	timer {
		get {
			return isObject(timer := this.__timer) ? timer : (this.__timer := ObjBindMethod(this, "call"))
		}
	}
	finish := ""
	finish_args {
		get {
			return IsObject(_args := this.__finish_args) ? _args : (this.__finish_args := [])
		}
		set {
			return this.__finish_args := isObject(value) ? value : []
		}
	}
	wait := true
	running := false
	start_tick := ""
	stop_tick := ""
	start_time := ""
	stop_time := ""
	__New(_timeout, _callback, _args*){
		this.timeout := _timeout
		this.callback := _callback
		this.args := _args
	}
	await(_wait := true){
		this.wait := !!_wait
		return this
	}
	then(_callback := "", _args*){
		this.finish := _callback
		this.finish_args := _args
		return this
	}
	listen(_toggle := true){
		if !this.running
			return
		timer := this.timer
		_on := _toggle ? "On" : "Off"
		SetTimer, %timer%, %_on%
	}
	run(){
		return this.start(true)
	}
	start(_run := false){
		if this.running
			return
		this.running := true
		this.start_time := A_Now
		this.start_tick := A_TickCount
		this.count := 0
		if _run
			this.call()
		timer := this.timer
		timeout := this.timeout
		priority := this.priority
		str = SetTimer, %timer%, %timeout%, %priority%
		MsgBox % str
		SetTimer, %timer%, %timeout%, %priority%
		return this
	}
	stop(){
		this.listen(false)
		if this.running
		{
			this.running := false
			this.stop_time := A_Now
			this.stop_tick := A_TickCount
			if IsFunc(finish := this.finish)
				%finish%(this.finish_args*)
		}
		return this
	}
	call(){
		wait := this.wait
		if wait
			this.listen(false)
		if !this.running
			return this.stop()
		if !IsFunc(callback := this.callback)
			throw Exception("Interval callback """ callback """ is not a valid function!", "XInterval Exception", "")
		this.count += 1
		result := %callback%(this.args*)
		if (result == -1 || this.timeout < 0)
			this.stop()
		else if wait
			this.listen()
	}
}
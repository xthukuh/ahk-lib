/*
	XDB Helper Class
	By Martin Thuku (2021-06-09 02:53:42)
	https://fiverr.com/martinthuku
	https://xthukuh.github.io
	
	Ref: https://github.com/AHK-just-me/Class_SQLiteDB
*/

;includes
#Include %A_LineFile%\..\..\xnum.ahk
#Include %A_LineFile%\..\..\xtrim.ahk
#Include %A_LineFile%\..\..\xfile.ahk
#Include %A_LineFile%\..\..\xis_array.ahk
#Include %A_LineFile%\..\..\xjson_encode.ahk
#Include %A_LineFile%\..\SQLiteDB.ahk

;db helper
class xdb_helper
{
	;static vars
	static db_file := "" ;default = A_ScriptDir "\" A_ScriptName(no ext) ".db"
	static db_dll := A_LineFile "\..\sqlite3.dll"
	static debug_callback := ""
	static debug_level := 0
	
	;new instance
	__New(file := "", fn_debug := "")
	{
		this.file := file
		this.fn_debug := fn_debug

		this.db := ""
		this.tables := ""
		this.tables_map := ""
		this.tables_list := ""
		this.tables_install := []
		this.transaction_begin := 0
	}

	;debug
	debug(msg, _level := 0)
	{
		if (_level < this.debug_level)
			return
		if _level
			this.error := msg
		if isFunc(fn := this.fn_debug)
			%fn%(msg, _level, "xdb")
		if isFunc(fn := this.debug_callback)
			%fn%(msg, _level, "xdb")
	}

	;validate name
	is_name(name)
	{
		if ((name := xtrim(name)) != "" && RegExMatch(name, "i)^[a-z][_a-z0-9]+$"))
			return name
	}

	;validate file
	is_file(file)
	{
		path := xpath(file, _error)
		if (path && !InStr(FileExist(path), "D"))
			return path
		if _error
			this.debug(_error)
	}

	;get file path
	get_file()
	{
		;return instance db file path
		if (tmp := this.is_file(this.file))
			return tmp
		if (tmp := this.is_file(this.base.db_file))
			return tmp
		
		;return default
		return xpath_split(A_ScriptFullPath,,, "db")
	}

	;escape sql value
	escape(val, _quotes := 0)
	{
		if val is integer
			return val
		if val is float
			return xnum(val)
		if isObject(val)
			val := xjson_encode(val)
		;val := StrReplace(val, "\", "\\")
		;val := StrReplace(val, """", "\""")
		val := StrReplace(val, "'", "''")
		return _quotes ? "'" val "'" : val
	}

	;SQLiteDB open (calls this.install() if this.tables_install is empty)
	open()
	{
		;unset instance db
		this.db := ""
		
		;check db files
		if !(file := xfile(this.get_file(file), _mkdir := 1, _error))
			return this.debug(xtrim("Invalid db file path. " _error), 2)
		if !(dll := xpath(tmp := this.base.db_dll, _error))
			return this.debug(xtrim("Invalid db dll file path. (" tmp ") " _error), 2)
		if !xis_file(dll)
			return this.debug("Could not find db dll file. (" dll ")", 2)
		
		;SQLiteDB set sqlite3.dll path
		SQLiteDB._SQLiteDLL := dll

		;SQLiteDB instance
		this.db := new SQLiteDB
		if !this.db.OpenDB(file)
			return this.debug("Failed to open db """ file """. " this.db_error(), 2)

		;db install tables
		if !xis_array(this.tables_install)
			this.install()
		
		;result
		return this.db
	}

	;SQLiteDB validate
	is_db(db)
	{
		return isObject(db) && db.__class == "SQLiteDB"
	}
	
	;SQLiteDB error
	db_error()
	{
		if this.is_db(db := this.db)
			return "DB Error [" db.ErrorCode "] " db.ErrorMsg
	}

	;SQLiteDB get instance
	get_db()
	{
		if !this.is_db(db := this.db)
			db := this.open()
		return db ? db : this.debug("SQLiteDB open failure!", 2)
	}

	;SQLiteDB exec
	exec(sql, _rollback := 0)
	{
		;get db
		if !(db := this.get_db())
			return
		
		;db exec
		if !(res := db.Exec(sql))
		{
			err := "DB Exec Failure!`n" sql
			err .= "`n" this.db_error()
			if _rollback
				err .= "`nrollback = " this.rollback()
			return this.debug(xtrim(err), 2)
		}
		
		;result
		return res
	}

	;SQLiteDB begin transaction
	begin()
	{
		if this.transaction_begin
			return
		return this.transaction_begin := this.exec("BEGIN TRANSACTION;")
	}

	;SQLiteDB commit transaction
	commit()
	{
		if !this.transaction_begin
			return
		if (res := this.exec("COMMIT;")) ;COMMIT TRANSACTION
			this.transaction_begin := 0
		return res
	}

	;SQLiteDB rollback transaction
	rollback()
	{
		if !this.transaction_begin
			return
		if (res := this.exec("ROLLBACK;"))
			this.transaction_begin := 0
		return res
	}

	;SQLiteDB get last insert id
	last_insert_id()
	{
		;get db
		if !(db := this.get_db())
			return
		
		;db exec
		if !db.LastInsertRowID(value)
			return this.debug(xtrim("DB LastInsertRowID Failure!`n" this.db_error()), 2)
		
		;result
		return value
	}

	;SQLiteDB query
	query(sql, ByRef _RecordSet := "")
	{
		;get db
		if !(db := this.get_db())
			return
		
		;db query
		if !db.Query(sql, _RecordSet)
		{
			err := "DB Query Failure!`n" sql
			err .= "`n" this.db_error()
			err .= "`nRecordSet Error [" _RecordSet.ErrorCode "] " _RecordSet.ErrorMsg
			return this.debug(xtrim(err), 2)
		}
		
		;set items
		cols := []
		items := []
		if _RecordSet.HasNames
		{
			loop, % _RecordSet.ColumnCount
				cols.Push(_RecordSet.ColumnNames[A_Index])
		}
		if ((cols_len := cols.Length()) > 0 && _RecordSet.HasRows)
		{
			if (_RecordSet.Next(row) < 1)
				return this.debug(xtrim("DB Query RecordSet Error [" _RecordSet.ErrorCode "] " _RecordSet.ErrorMsg), 2)
			loop
			{
				item := {}
				loop, % cols_len
				{
					col := cols[i := A_Index]
					val := row[i]
					item[col] := val
				}
				items.Push(item)
				next := _RecordSet.Next(row)
			}
			until (next < 1)
		}
		/*
		if ((cols_len := cols.Length()) > 0 && _RecordSet.HasRows)
		{
			while (_RecordSet.Next(row))
			{
				item := {}
				loop, % cols_len
				{
					col := cols[i := A_Index]
					val := row[i]
					item[col] := val
				}
				items.Push(item)
			}
		}
		*/
		_RecordSet.Free()

		;result
		return {columns: cols, items: items}
	}

	/*
		setup db tables (called before this.open())
		table and column name is required.
		i.e. tables := [...{
			name: "table_name",			;required
			columns: [...{
				name: "column_name", 	;required
				type: "TEXT", (NULL|INTEGER|REAL|TEXT|BLOB)
				primary: 0,
				unique: 0,
				nullable: 0,
				default: 0,
				foreign: [table, column, on_delete := "CASCADE", on_update := "NO ACTION"]
			}]
		}]
	*/
	setup(tables)
	{
		;check tables array
		if !(isObject(tables) && tables.Length())
			return this.debug("Invalid setup tables array.", 1)
		
		;instance vars
		db_tables := isObject(this.tables) ? this.tables : []
		db_tables_list := this.tables_list

		;setup tables
		loop, % tables.Length()
		{
			;table object
			table := tables[t := A_Index]
			if !isObject(table)
				continue

			;check table name
			if !(table.HasKey("name") && (name := this.is_name(table.name)))
			{
				this.debug("Invalid table name. (" t ")", 1)
				continue
			}

			;check duplicate table
			if name in % db_tables_list
			{
				this.debug("Duplicate table name """ name """. (" t ")", 1)
				continue
			}

			;check table columns
			if !(table.HasKey("columns") && isObject(cols := table.columns) && cols.Length())
			{
				this.debug("Table """ name """ has invalid columns. (" t ")", 1)
				continue
			}

			;table columns
			table_cols := []
			seen_cols := ""
			has_primary := ""
			loop, % cols.Length()
			{
				;column object
				col := cols[c := A_Index]
				table_col := {name: ""
					, type: "TEXT"
					, primary: 0
					, unique: 0
					, nulls: ""
					, default: ""
					, foreign: ""}
				if !isObject(col)
				{
					if !(col_name := this.is_name(col))
					{
						this.debug("Table [(" t ") " name "] Error: Invalid table column name. (" c ")", 1)
						continue
					}

					;column name
					table_col.name := col_name
					
					;column "id"
					if (col_name = "id")
					{
						if (has_primary != "")
						{
							;multiple primary key support error
							return this.debug("Table [(" t ") " name "] Error: Unsupported table columns setup. Cannot use primary key " col_name " (" c "). Primary key " has_primary " is already defined.", 2)
						}
						has_primary := col_name
						table_col.type := "INTEGER"
						table_col.primary := 1
					}
				}
				else {
					if !(col.HasKey("name") && (col_name := this.is_name(col.name)))
					{
						this.debug("Table [(" t ") " name "] Error: Invalid column name. (" c ")", 1)
						continue
					}

					;column name
					table_col.name := col_name

					;column type
					if col.HasKey("type")
					{
						col_type := Format("{:U}", xtrim(col.type))
						if !RegExMatch(col_type, "^(NULL|INTEGER|REAL|TEXT|BLOB)$")
							this.debug("Table [(" t ") " name "] Error: Invalid column """ col_name """ type """ col.type """. (" c ")")
						else
							table_col.type := col_type 
					}

					;column primary
					if (col.HasKey("primary") && col.primary)
					{
						if (has_primary != "")
						{
							;multiple primary key support error
							return this.debug("Table [(" t ") " name "] Error: Unsupported table columns setup. Cannot use primary key " col_name " (" c "). Primary key " has_primary " is already defined.", 2)
						}
						table_col.primary := 1
						has_primary := col_name
					}
					
					;column unique
					if (col.HasKey("unique") && col.unique)
						table_col.unique := 1
					
					;column nulls
					if !table_col.primary
						table_col.nulls := "NOT NULL"
					if (col.HasKey("nulls") && (col_nulls := Format("{:U}", xtrim(col.nulls))) && (col_nulls == "NOT NULL" || col_nulls == "NULL"))
						table_col.nulls := col_nulls
					
					;column default
					if (col.HasKey("default") && (col_default := xtrim(col.default)) != "")
						table_col.default := col_default
					
					;column foreign
					if (col.HasKey("foreign") && isObject(col_foreign := col.foreign) && col_foreign.Length() >= 2)
					{
						ftable := this.is_name(col_foreign[1])
						fcol := this.is_name(col_foreign[2])
						if (ftable && fcol)
						{
							on_delete := "CASCADE"
							on_update := "NO ACTION"
							pattern := "^(NO ACTION|RESTRICT|SET NULL|SET DEFAULT|CASCADE)$"
							if (col_foreign.Length() > 2 && RegExMatch(tmp := Format("{:U}", xtrim(col_foreign[3])), pattern))
								on_delete := tmp
							if (col_foreign.Length() > 3 && RegExMatch(tmp := Format("{:U}", xtrim(col_foreign[4])), pattern))
								on_update := tmp
							table_col.foreign := [ftable, fcol, on_delete, on_update]
						}
						else this.debug("Table [(" t ") " name "] Error: Invalid column """ col_name """ foreign relationship. (" c ")")
					}

					;todo: support more options
				}

				;check column object
				if !((col_name := table_col.name) && table_col.type)
				{
					this.debug("Table [(" t ") " name "] Error: Failed to get table column. (" c ")", 1)
					continue
				}

				;check duplicate column
				if col_name in % seen_cols
				{
					this.debug("Table [(" t ") " name "] Error: Duplicate column name """ col_name """. (" c ")", 1)
					continue
				}

				;add table column
				table_cols.Push(table_col)
				seen_cols .= (seen_cols != "" ? "," : "") col_name
			}

			;check table columns
			if !table_cols.Length()
			{
				this.debug("Failed to get table """ name """ columns. (" t ")", 1)
				continue
			}

			;columns map - names => index
			map := Object()
			loop, % table_cols.Length()
				map[table_cols[A_Index].name] := A_Index

			;add db table
			db_tables.Push({name: name, columns: table_cols, columns_map: map})
			db_tables_list .= (db_tables_list != "" ? "," : "") name
		}

		;check db tables
		if !db_tables.Length()
			return this.debug("Failed to get db tables.", 1)
		
		;map tables - names => index
		map := Object()
		loop, % db_tables.Length()
			map[db_tables[A_Index].name] := A_Index
		
		;update instance vars
		this.tables_map := map
		this.tables := db_tables
		this.tables_list := db_tables_list

		;result - tables count
		return this.tables.Length()
	}

	/*
		get tables setup create queries array
		i.e. [...'CREATE TABLE IF NOT EXIST...']
		called after this.setup([...TABLE_CONFIG])
	*/
	tables_create()
	{
		;create tables buffer - [...create table query]
		tables_create := []
		tables := this.tables
		tables_map := this.tables_map
		if (isObject(tables) && tables.Length() && isObject(tables_map) && tables_map.Count())
		{
			order := []
			loop, % tables.Length()
			{
				;create table query
				table := tables[t := A_Index]
				table_query := "CREATE TABLE IF NOT EXISTS " table.name " ("
				
				;create table columns query
				foreign_keys := []
				primary_keys := ""
				loop, % table.columns.Length()
				{
					;create column
					col := table.columns[c := A_Index]
					col_query := col.name " " col.type
					
					;col nulls
					if (col.nulls != "")
						col_query .= " " col.nulls
					
					;col primary
					if col.primary
						primary_keys .= (primary_keys != "" ? ", " : "") col.name

					;col unique
					if col.unique
						col_query .= " UNIQUE"
					
					;col default
					if (col.default != "")
						col_query := " DEFAULT " this.escape(col.default, 1)
					
					;col foreign
					if (isObject(col.foreign) && col.foreign.Length() >= 4)
					{
						ftable := col.foreign[1]
						fcol := col.foreign[2]
						tmp := "FOREIGN KEY (" col.name ")"
						tmp .= "`n`tREFERENCES " ftable " (" fcol ")"
						tmp .= "`n`tON DELETE " col.foreign[3]
						tmp .= "`n`tON UPDATE " col.foreign[4]
						foreign_keys.Push([col.name, tmp, ftable, fcol])
					}

					;todo: support more column options
					;add column query
					table_query .= (c > 1 ? "," : "") "`n`t" col_query
				}

				;primary keys
				if primary_keys !=
					table_query .= ",`n`tPRIMARY KEY (" primary_keys ")"
				
				;foreign keys [...{1: col_name, 2: query, 3: ftable, 4: fcol}]
				foreign_tables := []
				if foreign_keys.Length()
				{
					seen_tables := ""
					loop, % foreign_keys.Length()
					{
						foreign_key := foreign_keys[A_Index]
						table_query .= ",`n`t" foreign_key[2]
						ftable := foreign_key[3]
						if ftable not in % seen_tables
						{
							foreign_tables.Push(ftable)
							seen_tables .= (seen_tables != "" ? "," : "") ftable
						}
					}
				}

				;table query end
				table_query .= "`n)"

				;order index
				order_index := 0
				if order.Length()
				{
					loop, % order.Length()
					{
						if (order[A_Index] == table.name)
						{
							order_index := A_Index
							break
						}
					}
				}

				;set order after foreign tables
				if foreign_tables.Length()
				{
					if order_index
						order.InsertAt(order_index, foreign_tables*)
					else order.Push(foreign_tables*)
				}
				if !order_index
					order.Push(table.name)

				;set table query
				table.create_query := table_query
			}

			;set create tables
			order_seen := ""
			loop, % order.Length()
			{
				name := order[A_Index]
				if name in % order_seen
					continue
				if !isObject(table := tables[tables_map[name]])
					return this.debug("Failed to get map table """ name """.", 2)
				tables_create.Push(table.create_query)
				order_seen .= (order_seen != "" ? "," : "") name
			}
		}

		;result
		return tables_create
	}

	;install tables
	install()
	{
		;create queries
		if !(len := xis_array(tables_create := this.tables_create()))
			return this.debug("Tables create setup failure.", 2)
		
		;create tables
		tables_install := []
		this.begin()
		loop, % len
		{
			sql := tables_create[i := A_Index]
			if !this.exec(sql, 1)
				return this.debug("Failed to create table at (" i ").", 1)
			tables_install.Push(sql)
		}
		this.commit()
		
		;result
		return this.tables_install := tables_install
	}

	;table setup
	table_setup(table_name)
	{
		;check instance tables
		if !(isObject(this.tables) && this.tables.Length())
			return this.debug("Undefined tables.", 2)
		
		;check tables map
		if !(isObject(this.tables_map)
			&& this.tables_map.HasKey(table_name)
			&& isObject(table := this.tables[this.tables_map[table_name]]))
			return this.debug("Table """ table_name """ is not setup.", 2)
		
		;result
		return table
	}

	;table config
	table_config(table_name)
	{
		;table
		if !isObject(table := this.table_setup(table_name))
			return
		
		;check table columns
		if !isObject(table.columns)
			return this.debug("Table """ table_name """ columns is undefined.", 2)
		
		;check table columns map
		if !isObject(table.columns_map)
			return this.debug("Table """ table_name """ columns map is undefined.", 2)
		
		;column names
		col_names := []
		for i, col in table.columns
		{
			if !(isObject(col) && col.HasKey("name") && StrLen(name := xtrim(col.name)))
				return this.debug("Table """ table_name """ column config at (" i ") is invalid.", 2)
			col_names.Push(name)
		}

		;column options object {..."column_name": "opts (TYPE|PRIMARY|NULLABLE|DEFAULT=VALUE)"}
		col_opts := Object()
		primary_key := ""
		foreign_keys := ""
		for key, index in table.columns_map
		{
			;check column config
			if !(isObject(col := table.columns[index])
				&& col.HasKey("type")
				&& col.HasKey("foreign")
				&& col.HasKey("default")
				&& col.HasKey("primary")
				&& col.HasKey("nulls"))
				return this.debug("Table """ table_name """ column config (" key "," index ") is invalid.", 2)
			
			;foreign keys
			if xis_array(col.foreign)
			{
				if !isObject(foreign_keys)
					foreign_keys := {}
				foreign_keys[col.name] := [col.foreign[1], col.foreign[2]]
			}

			;col options
			opts := col.type
			if col.primary
			{
				opts .= "|PRIMARY"
				primary_key := col.name
			}
			if (opts.nulls == "NULL")
				opts .= "|NULLABLE"
			if ((val := opts.default) != "")
				opts .= "|DEFAULT=" val
			col_opts[key] := opts
		}

		;check primary key
		if !(primary_key != "")
			return this.debug("Table """ table_name """ config has no primary key.", 2)
		
		;result
		return {name: table_name
			, columns: col_names
			, options: col_opts
			, primary_key: primary_key
			, foreign_keys: foreign_keys}
	}

	;validate table config
	is_table_config(config)
	{
		return isObject(config)
			&& config.HasKey("name")
			&& config.HasKey("columns")
			&& config.HasKey("options")
			&& config.HasKey("primary_key")
			&& config.HasKey("foreign_keys")
	}

	;table rows count
	get_columns(table_name)
	{
		;table_config
		if !this.is_table_config(table_config := this.table_config(table_name))
			return
		
		;result
		return table_config.columns
	}

	;table rows count
	get_count(table_name)
	{
		if !(table_name := xtrim(table_name))
			return
		sql := "SELECT COUNT(*) AS _count FROM " table_name ";"
		if !(res := this.query(sql))
			return
		if (isObject(res) && res.HasKey("items") && xis_array(res.items))
		{
			if (isObject(item := res.items[1]) && item.HasKey("_count"))
				return item._count
			return 0
		}
	}

	;table rows count
	get_items(table_name, _limit := 0, _offset := 0, _order_col := "", _order_desc := 0)
	{
		if !(table_name := xtrim(table_name))
			return
		sql := "SELECT * FROM " table_name
		if (_order_col := xtrim(_order_col))
			sql .= " ORDER BY " _order_col " " (_order_desc ? "DESC" : "ASC")
		if ((_limit := xint(_limit)) > 0)
		{
			sql .= " LIMIT " _limit
			if ((_offset := xint(_offset)) > 0)
				sql .= " OFFSET " _offset
		}
		if !(res := this.query(sql))
			return
		if (isObject(res) && res.HasKey("items") && isObject(res.items))
			return res.items
	}

	;find item by primary key value (id)
	find(table_name, value, table_config := "")
	{
		if !this.is_table_config(table_config) && !isObject(table_config := this.table_config(table_name))
			return
		sql := "SELECT * FROM " table_name " WHERE " table_config.primary_key " = " this.escape(value, 1) ";"
		if !(res := this.query(sql))
			return
		if (isObject(res) && res.HasKey("items") && xis_array(items := res.items))
		{
			if isObject(item := items[1])
				return item
		}
	}

	;delete item by primary keys
	delete(table_name, values*)
	{
		if !this.is_table_config(table_config) && !isObject(table_config := this.table_config(table_name))
			return
		this.begin()
		deleted := []
		col := table_config.primary_key
		for i, val in values
		{
			if ((val := xtrim(val)) == "")
				continue
			val := this.escape(val, 1)
			sql := "DELETE FROM " table_name " WHERE " col " = " val ";"
			if !(res := this.exec(sql, 1))
				return this.debug("Delete failed at (" i " - " col " => " val ")", 1)
			deleted.Push(val)
		}
		this.commit()
		return deleted
	}

	/*
		insert/update table data
		_input := {column => value}
		_input := [...{column => value}]
		if primary key is present, data will be updated otherwise inserted.
		_saved_input is updated with the retrieved saved item data.
	*/
	save(table_name, _input, xdb := "")
	{
		;table config {name, columns, options, primary_key}
		if this.is_table_config(table_config := table_name)
			table_name := table_config.name
		else if !isObject(table_config := this.table_config(table_name))
			return
		
		;check input type
		input_type := 0 ;0 = invalid, 1 = object, 2 = array
		if (isObject(_input) && _input.Count())
		{
			if xis_array(_input)
			{
				for k, v in _input
				{
					if !(isObject(v) && !xis_array(v))
						return this.debug("Invalid save array input for table """ table_name """ at (" k ").", 2)
				}
				input_type := 2
			}
			else input_type := 1
		}

		;invalid input
		if !input_type
			return this.debug("Invalid save input for table """ table_name """.", 2)
		
		;array input save recursively
		if (input_type == 2)
		{
			;save input
			this.begin()
			saved_items := []
			for i, item in _input
			{
				;save input item
				if !isObject(saved_item := this.save(table_config, item))
				{
					this.rollback()
					return this.debug("Table """ table_name """ save input at (" i ") failed.", 1)
				}
				saved_items.Push(saved_item)
			}
			this.commit()
			
			;result
			return saved_items
		}

		;query data
		query_cols := ""
		query_vals := ""
		query_sets := ""
		primary_val := ""
		primary_key := table_config.primary_key
		for i, col_name in table_config.columns
		{
			;ignore column not in input
			if !_input.HasKey(col_name)
				continue
			
			;col input
			val := _input[col_name]

			;col options
			col := table_config.options[col_name]

			;col primary key
			col_primary := 0
			if col contains PRIMARY
				col_primary := 1

			;blank value
			if (val == "")
			{
				;omit primary key if blank
				if col_primary
					continue
				
				;set blank nullable value (NULL)
				if col contains NULLABLE
					val := "NULL"
			}
			else {
				;input value
				tmp := val

				;integer
				if col contains INTEGER
					tmp := xint(tmp, "")
				
				;real
				if col contains REAL
					tmp := xnum(tmp, "")
				
				;check value
				if (val != "" && tmp == "")
					return this.debug("Column """ table_name "." col_name """ input value is invalid.", 2)
				
				;update value
				val := tmp
			}

			;set query data
			val := this.escape(val, 1)
			if (col_name == primary_key)
				primary_val := val
			else query_sets .= (query_sets != "" ? ", " : "") col_name " = " val
			query_cols .= (query_cols != "" ? "," : "") col_name
			query_vals .= (query_vals != "" ? "," : "") val
		}
		if !(query_cols != "" && query_vals != "")
			return this.debug("Table """ table_name """ save input is invalid", 1)

		;query existing
		existing := ""
		if primary_val !=
			existing := this.find(table_name, primary_val, table_config)
		
		;query sql
		is_new := 0
		if !(isObject(existing) && existing[primary_key] == primary_val)
		{
			is_new := 1
			sql := "INSERT INTO " table_name " (" query_cols ") VALUES (" query_vals ");"
		}
		else sql := "UPDATE " table_name " SET " query_sets " WHERE " primary_key " = " primary_val ";"
		
		;query exec
		if !this.exec(sql)
			return this.debug(xtrim("Save into table " table_name " failed!"), 1)
		
		;insert set id
		if is_new
			primary_val := this.last_insert_id()
		
		;saved item
		saved := (isObject(res := this.find(table_name, primary_val, table_config))
			&& res.HasKey(primary_key)
			&& res[primary_key] == primary_val) ? res : "ERROR"
		
		;result
		return saved
	}
}
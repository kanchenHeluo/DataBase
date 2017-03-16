Data access in db
	1- CLRSQL
	2- Sql in client: Compose sql string in client
		a. Build entire sql with paramters expanded - 有 reuse, sql injection 问题
		b. use parameterised queries 
	3-  Perform acess through store procedure
		a. Static sql -- 没问题，因为只需要执行sp权限
		b. Static & dynamic sql -- 按需求可以强大。否则直接用1-b即可。- 同样注意Sql injection问题。

Dynamic sql
例子：
DECLARE @tbl    sysname,
        @sql    nvarchar(4000),
        @params nvarchar(4000),
        @count  int
DECLARE tblcur CURSOR STATIC LOCAL FOR
   SELECT object_name(id) FROM syscolumns WHERE name = 'LastUpdated'
   ORDER  BY 1
OPEN tblcur
WHILE 1 = 1
BEGIN
   FETCH tblcur INTO @tbl
   IF @@fetch_status <> 0
      BREAK
SELECT @sql =
   N'  SELECT @cnt = COUNT(*) FROM dbo.' + quotename(@tbl) +
   N'  WHERE LastUpdated BETWEEN @fromdate AND ' +
   N'                           coalesce(@todate, ''99991231'')'
   SELECT @params = N' @fromdate datetime, ' +
                    N' @todate   datetime = NULL, ' +
                    N' @cnt      int      OUTPUT'
   EXEC sp_executesql @sql, @params, '20060101', @cnt = @count OUTPUT
PRINT @tbl + ': ' + convert(varchar(10), @count) + ' modified rows.'
END
DEALLOCATE tblcur

注意的点：
	1. Quotername 解析tablename
	2. 所执行的sql必须是 N''的。Sql_executesql不做varchar->nvarchar的强行转换 
	3. 拼凑语句前加个空格是好习惯，避免缺空格。
	4. 不能拼接语法上无意义的sql parameter在@sql中。


Sql injection
	1. Never run with more privileges than necessary. Users that log into an application with their own login should normally only have EXEC permissions on stored procedures. If you use dynamic SQL, it should be confined to reading operations so that users only need SELECT permissions. A web site that logs into a database should not have any elevated privileges, preferably only EXEC and (maybe) SELECT permissions. Never let the web site log in as sa!
	2. For web applications: never expose error messages from SQL Server to the end user.
	3. Always used parameterised statements. That is, in a T-SQL procedure use sp_executesql, not EXEC().
	4. you cannot pass everything as parameters to dynamic SQL, for instance table and column names. In this case you must enclose all such object names in quotename()

http://www.sommarskog.se/dynamic_sql.html#forks
--A snippet for some quick table statistics

--Config 
-----------------------------------------------------
--Get the Top N most common values in your table
DECLARE @TopN INT = 5 

--Name of Table to Analyze
DECLARE @TableName VARCHAR(100) = ''

--In case you want to filter anything out such as nulls
DECLARE @WhereCondition VARCHAR(MAX) = ''
-----------------------------------------------------


DECLARE @TableID INT

SELECT @TableID = Object_id FROM sys.tables t where t.name like @TableName

DECLARE @ColumnName VARCHAR(max)

DECLARE Column_Cursor CURSOR FOR
SELECT c.name
FROM Sys.columns c
WHERE c.object_id = @TableID
AND c.is_identity = 0

DECLARE @TotalCnt INT 

DECLARE @CountSQL VARCHAR(max) = '(SELECT COUNT(*) FROM ' + @TableName + ' )'

OPEN Column_Cursor
FETCH NEXT FROM Column_cursor INTO @ColumnName

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE @MainSQL VARCHAR(max) = 'SELECT TOP ' + CAST(@TopN AS VARCHAR) + ' ' + @ColumnName + ', Count(*) as Cnt, 100.0*Count(*)/' +  @CountSQL   + ' as [Percent of Rows]'

	SET @MainSQL = @MainSQL + ' FROM ' + @TableName

	SET @MainSQL = @MainSQL + ' ' + 'GROUP BY ' + @ColumnName

	SET @MainSQL = @MainSQL + ' ' + @WhereCondition

	SET @MainSQL = @MainSQL + ' ' + 'ORDER BY Cnt DESC'

	EXEC (@MainSQL)

	FETCH NEXT FROM Column_Cursor INTO @ColumnName
END

CLOSE Column_Cursor
DEALLOCATE Column_Cursor


SELECT 
CASE Sum((st.user_seeks*1.0 + st.user_scans + st.user_lookups + st.user_updates))
	WHEN 0 THEN -1
	ELSE  100 *  Sum((st.user_seeks*1.0 + st.user_scans + st.user_lookups))/SUM((st.user_seeks + st.user_scans + st.user_lookups + st.user_updates))
END as [Table Read %],

CASE SUM((st.user_seeks*1.0 + st.user_scans + st.user_lookups + st.user_updates))
	WHEN 0 THEN -1
	ELSE   100 *  Sum(st.user_updates*1.0)/SUM((st.user_seeks + st.user_scans + st.user_lookups + st.user_updates))
END as [Table Write %] 
FROM sys.dm_db_index_usage_stats st
where st.Object_Id = @TableID


--A quick snippet to get some read and write statistics for indexes.

SELECT 
CONCAT(s.name, '.', t.name) as [Table Name],
c.name as [Column Name],
i.name as [Index Name],
i.type_desc as [Index Type],
CASE i.is_primary_key 
 WHEN 0 THEN 'NO'
 ELSE 'YES'
END as [Primary Key],

CASE (st.user_seeks + st.user_scans + st.user_lookups)
	WHEN 0 THEN -1
	ELSE 100 * st.user_seeks/(st.user_seeks + st.user_scans + st.user_lookups)
END as [Seek Read %],

CASE (st.user_seeks + st.user_scans + st.user_lookups)
	WHEN 0 THEN -1
	ELSE  100 *  st.user_scans/(st.user_seeks + st.user_scans + st.user_lookups)
END as [Scan Read %],

CASE (st.user_seeks + st.user_scans + st.user_lookups)
	WHEN 0 THEN -1
	ELSE   100 * st.user_lookups/(st.user_seeks + st.user_scans + st.user_lookups)
END as [Lookup Read %],

(st.user_seeks + st.user_scans + st.user_lookups) as [Total Reads],
st.user_updates as [Total Writes (user_updates)],

CASE (st.user_seeks + st.user_scans + st.user_lookups + st.user_updates)
	WHEN 0 THEN -1
	ELSE  100 *  (st.user_seeks + st.user_scans + st.user_lookups)/(st.user_seeks + st.user_scans + st.user_lookups + st.user_updates)
END as [Reads %],

CASE (st.user_seeks + st.user_scans + st.user_lookups + st.user_updates)
	WHEN 0 THEN -1
	ELSE   100 *  st.user_updates/(st.user_seeks + st.user_scans + st.user_lookups + st.user_updates)
END as [Writes %] 
FROM sys.dm_db_index_usage_stats st
JOIN sys.tables t on st.object_id = t.object_id
join sys.schemas s on t.schema_id = s.schema_id
JOIN sys.indexes i on i.object_id = st.object_id 
					AND i.index_id = st.index_id
JOIN sys.index_columns ic on ic.index_id = i.index_id 
					AND ic.object_id = i.object_id
Join sys.columns c on c.column_id = ic.column_id 
					AND c.object_id = ic.object_id
WHERE st.database_id = DB_ID()	
	AND i.is_disabled = 0 --index is enabled
ORDER BY [Total Reads] DESC



--Search for tables containing 1 column name
SELECT t.name as [Table Name], c.name as [Column Name]
FROM sys.tables t 
JOIN sys.columns c on t.object_Id = c.object_id
WHERE c.name LIKE '%%'




--Search for tables containing these 2 columns
SELECT t.name as [Table Name], c1.name as [Column 1], c2.name as [Column 2] 
FROM sys.tables t 
JOIN sys.columns c1 on t.object_Id = c1.object_id
JOIN sys.columns c2 on t.object_Id = c2.object_id
WHERE c1.name LIKE '%%'
AND c2.name LIKE '%%'



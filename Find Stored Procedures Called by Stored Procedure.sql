------------------------------------------------------------------------------------
--BEGIN
------------------------------------------------------------------------------------

DECLARE @ProcName Varchar(max) = ''
DECLARE @RowCount INT = 0

IF OBJECT_ID('tempdb..#SpCallListTemp') IS NOT NULL DROP TABLE #SpCallListTemp

CREATE TABLE #SpCallListTemp
(
	CallingSP VARCHAR(max), 
	CalledSP VARCHAR (max)
)

INSERT INTO #SpCallListTemp (CallingSp, CalledSp)
Values ('You', @ProcName )

WHILE (1=1) --loop until break condition
BEGIN
	INSERT INTO #SpCallListTemp
	SELECT 
		o.name AS ReferencingObject, 
		sd.referenced_entity_name AS ReferencedObject
	FROM sys.sql_expression_dependencies  AS sd
		INNER JOIN sys.objects AS o ON o.object_id = sd.referencing_id
	WHERE o.name IN (
					 SELECT CalledSp 
					 FROM #SpCallListTemp 
					 WHERE CalledSp NOT IN(SELECT CallingSp FROM #SpCallListTemp)
					 )
		AND sd.referenced_entity_name in (SELECT name FROM sys.objects WHERE type LIKE 'P')

	--If we didn't gain any new rows we can break
	IF (@RowCount = (SELECT Count(*) FROM #SpCallListTemp)) 
	BEGIN
		Break
	END

	SET @RowCount = (SELECT Count(*) FROM #SpCallListTemp)

END

SELECT * FROM #SpCallListTemp

------------------------------------------------------------------------------------
--END
------------------------------------------------------------------------------------

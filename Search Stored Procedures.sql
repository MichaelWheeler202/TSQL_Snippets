--------------------------------------------
----------------   Start    -----------------
---------------------------------------------
    DECLARE @ProcString VARCHAR(MAX)= '%CSP_ServiceNoteProgramId%';

    SELECT  Row_number() over (order by t.type_desc, t.name) as RN, t.name AS 'SP Name'
            ,(SELECT [processing-instruction(i)] = OBJECT_DEFINITION(t.OBJECT_ID)
            FOR
            XML PATH('')
                ,TYPE
            ) AS 'code'
            ,T.create_date AS 'Created'
            ,t.modify_date AS 'modified'  
    FROM    sys.objects t
    WHERE   OBJECT_DEFINITION(t.OBJECT_ID) LIKE @ProcString
            AND t.type IN (N'P', N'PC')
    ORDER BY t.Type_Desc
            ,t.name    
---------------------------------------------
----------------    End     -----------------
---------------------------------------------
SET LANGUAGE SPANISH
SELECT 0 AS Orden,CONVERT(VARCHAR(30),GETDATE(),1) AS ResultadoPrimerValor,'1' AS PrimerValor
,CONVERT(VARCHAR(30),GETDATE(),101) AS ResultadoSegundoValor,'101' AS SegundoValor
,'mm/dd/aa o mm/dd/aaaa' AS Formato,'EEUU' AS OrigenFormato
UNION
SELECT 1,CONVERT(VARCHAR(30),GETDATE(),2) ,'2',CONVERT(VARCHAR(30),GETDATE(),102) ,'102' 
,'aa.mm.dd o aaaa.mm.dd' ,'ANSI' 
UNION
SELECT 2,CONVERT(VARCHAR(30),GETDATE(),3) ,'3',CONVERT(VARCHAR(30),GETDATE(),103) ,'103' 
,'dd/mm/aa o dd/mm/aaaa' ,'Británico/Francés' 
UNION
SELECT 3,CONVERT(VARCHAR(30),GETDATE(),4) ,'4',CONVERT(VARCHAR(30),GETDATE(),104) ,'104' 
,'dd.mm.aa o dd.mm.aaaa' ,'Alemán'  
UNION
SELECT 4,CONVERT(VARCHAR(30),GETDATE(),5) ,'5',CONVERT(VARCHAR(30),GETDATE(),105) ,'105' 
,'dd-mm-aa o dd-mm-aaaa' ,'Italiano' 
UNION
SELECT 5,CONVERT(VARCHAR(30),GETDATE(),6) ,'6',CONVERT(VARCHAR(30),GETDATE(),106) ,'106'  
,'dd mes aa o dd-mm-aaaa' ,'' 
UNION
SELECT 6,CONVERT(VARCHAR(30),GETDATE(),7) ,'7',CONVERT(VARCHAR(30),GETDATE(),107) ,'107' 
,'Mes dd, aa o Mes dd, aaaa' ,'' 
UNION
SELECT 7,CONVERT(VARCHAR(30),GETDATE(),8) ,'8, 24 o 108','' ,'' 
,'hh:mi:ss(24h)' ,'' 
UNION
SELECT 8,CONVERT(VARCHAR(30),GETDATE(),9) ,'9 o 109','' ,'' 
,'Mes dd aaaa hh:mi:ss:mmm(12h)' ,'' 
UNION
SELECT 9,CONVERT(VARCHAR(30),GETDATE(),10) ,'10',CONVERT(VARCHAR(30),GETDATE(),110) ,'110' 
,'mm-dd-aa o mm-dd-aaaa' ,'EEUU' 
UNION
SELECT 10,CONVERT(VARCHAR(30),GETDATE(),11) ,'11',CONVERT(VARCHAR(30),GETDATE(),111) ,'111' 
,'aa/mm/dd o aaaa/mm/dd' ,'JAPÓN'
UNION
SELECT 11,CONVERT(VARCHAR(30),GETDATE(),12) ,'12',CONVERT(VARCHAR(30),GETDATE(),112) ,'112' 
,'aammdd o aaaammdd' ,'ISO'
UNION
SELECT 12,CONVERT(VARCHAR(30),GETDATE(),13) ,'13 o 113','','' 
,'dd mes aaaa hh:mi:ss:mmm(24h)' ,'Europa'
UNION
SELECT 13,CONVERT(VARCHAR(30),GETDATE(),14) ,'14 o 114','','' 
,'hh:mi:ss:mmm' ,''
UNION
SELECT 14,CONVERT(VARCHAR(30),GETDATE(),20) ,'20 o 120','','' 
,'aaaa-mm-dd hh:mi:ss(24h)' ,'ODBC canónico'
UNION
SELECT 15,CONVERT(VARCHAR(30),GETDATE(),21) ,'21, 25 o 121','','' 
,'aaaa-mm-dd hh:mi:ss.mmm(24h)' ,'ODBC canónico (con milisegundos)'
UNION
SELECT 16,CONVERT(VARCHAR(30),GETDATE(),22) ,'22','','' 
,'mm/dd/aa hh:mi:ss(12h)' ,'EEUU'
UNION
SELECT 17,CONVERT(VARCHAR(30),GETDATE(),23) ,'23','','' 
,'aaaa-mm-dd' ,'ISO8601'
UNION
SELECT 18,CONVERT(VARCHAR(30),GETDATE(),126) ,'126 o 127','','' 
,'aaaa-mm-ddThh:mi:ss.mmm' ,'ISO8601'
ORDER BY 1 DESC

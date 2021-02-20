SELECT OBJECT_NAME(object_id) AS NombreObjeto 
,last_execution_time AS FechaEjecucion
,*
FROM sys.dm_exec_procedure_stats
WHERE OBJECT_NAME(object_id) IS NOT NULL
ORDER BY 2 DESC

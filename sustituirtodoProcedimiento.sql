	
	USE GSS_SERVICIOS_FILIASSUR
	
	DECLARE @ConsultaSQL AS NVARCHAR(MAX)
	DECLARE @TablaQuerys AS TABLE (Id INT IDENTITY(1,1),Query NVARCHAR(MAX))
	
	INSERT INTO @TablaQuerys (Query)
	SELECT REPLACE(REPLACE(REPLACE(DEFINITION,'VIEJO_VALOR','NUEVO_VALOR'),'CREATE PROCEDURE','ALTER PROCEDURE'),'CREATE VIEW','ALTER VIEW') AS Query
	FROM sys.sql_modules AS ss INNER JOIN sys.objects AS o ON o.[object_id] = ss.[object_id] 
	WHERE (o.name LIKE 'rs_%' OR o.name LIKE 'v_%' OR o.name LIKE 'pa_%') AND ss.DEFINITION LIKE '%ggeorgieva@grupogss.com%' 

	DECLARE @Conteo AS INT = (SELECT COUNT('') AS COnteo FROM @TablaQuerys)

	WHILE @Conteo > 0
		BEGIN
			
			SET @ConsultaSQL = (SELECT Query FROM @TablaQuerys WHERE Id = @Conteo)

			EXEC sp_executesql @ConsultaSQL

			SET @Conteo = @Conteo-1
		END

DECLARE @Busqueda AS NVARCHAR (255) = 'M_XIMO'


  DECLARE @TablasBBDD AS TABLE (ID INT IDENTITY(1,1), NombreBBDD NVARCHAR(255))
  
  DECLARE @Resultados AS TABLE (ID INT IDENTITY(1,1), NombreBBDD NVARCHAR(255),Procedimiento NVARCHAR(255))

  DECLARE @Conteo AS INT, @NombreBBDD AS NVARCHAR(255),@ConsultaSQL NVARCHAR(MAX)

  INSERT INTO @TablasBBDD (NombreBBDD)
  SELECT name FROM sys.databases
  WHERE 1=1
  --AND name  LIKE '%CCC%' --AND name LIKE '%GLOBAL%'
  AND name = DB_NAME()
  --B1301_AIG_CTF_2133	pa_BAJAS_CORTEFIEL
  SET @Conteo = (SELECT COUNT('') AS Conteo FROM @TablasBBDD)

  WHILE @Conteo > 0

	BEGIN
		
		SET @NombreBBDD = (SELECT NombreBBDD FROM @TablasBBDD WHERE ID=@Conteo)

		IF HAS_DBACCESS (@NombreBBDD)=1
			BEGIN

				SET @ConsultaSQL = (SELECT 
									'SELECT '''+@NombreBBDD+''' AS NombreBBDD,o.name AS Procedimiento '+
  									'FROM ['+@NombreBBDD+'].sys.sql_modules AS ss WITH (NOLOCK) '+
									'INNER JOIN ['+@NombreBBDD+'].sys.objects AS o  WITH (NOLOCK) ON o.[object_id] = ss.[object_id]  '+
									'WHERE  ss.DEFINITION LIKE ''%'+@Busqueda+'%''  '+
									--'AND ss.DEFINITION LIKE ''%UCICORECLDB%''  '+
									''
									) --Fin Consulta
				INSERT INTO @Resultados (NombreBBDD,Procedimiento)
				EXEC sp_executesql @ConsultaSQL

			END --Fin Condicion ACCESO BBDD

	SET @Conteo = @Conteo -1
	END --Fin Bucle


	SELECT *
	FROM @Resultados

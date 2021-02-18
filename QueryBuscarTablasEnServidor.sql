

DECLARE @TablasLocalizadas AS TABLE (Id INT IDENTITY(1,1),NombreTablaBuscar NVARCHAR(255),NombreTablaCompleto NVARCHAR(255))

DECLARE @ValorTablaBuscar NVARCHAR(255)
SET @ValorTablaBuscar = 'MTD%' --especificar valor porcentaje para aplicar como un LIKE


--VARIABLES PARA USO BUSQUEDA

DECLARE @NombreBBDD AS  NVARCHAR(255),@ConteoBBDD  INT,@ConsultaSQL NVARCHAR(4000)
DECLARE @TablaBBDD AS TABLE (Id INT IDENTITY(1,1),NombreBBDD NVARCHAR(255))

INSERT INTO @TablaBBDD (NombreBBDD)

SELECT d.name
FROM sys.databases d

SET @ConteoBBDD = (SELECT COUNT('') AS  Conteo FROM @TablaBBDD)

WHILE @ConteoBBDD > 0
	BEGIN
		SET @NombreBBDD = (SELECT NombreBBDD FROM @TablaBBDD WHERE Id = @ConteoBBDD)
		
		IF HAS_DBACCESS (@NombreBBDD) = 1
			BEGIN
				--SELECT 'hol'
				SET @ConsultaSQL = (SELECT 
									'SELECT s.name+''.''+t.name AS TablaBuscar,'''+@NombreBBDD+'.''+s.name+''.''+t.name AS NombreTablaCompleta '+
									'FROM ['+@NombreBBDD+'].sys.tables t '+
									'INNER JOIN ['+@NombreBBDD+'].sys.schemas s ON s.schema_id = t.schema_id '+
									'WHERE 1=1 '+
									'AND t.name LIKE '''+@ValorTablaBuscar+''' '

									)--FIn Consulta
				INSERT INTO @TablasLocalizadas (NombreTablaBuscar,NombreTablaCompleto)
				EXEC sys.sp_executesql @ConsultaSQL			

			END --Fin Condición acceso BBDD

	SET @ConteoBBDD = @ConteoBBDD -1
	END --Fin Bucle


SELECT Id,NombreTablaBuscar,NombreTablaCompleto
FROM @TablasLocalizadas





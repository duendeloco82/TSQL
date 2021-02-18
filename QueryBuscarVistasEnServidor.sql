
--BUSCAR VISTAS EN TODO EL SERVIDOR

--ESCRIBE EL NOMBRE DE LA  VISTA, BUSCARA LOS QUE CONTENGAN ESE TEXTO
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DECLARE @Busqueda NVARCHAR(255) = ''
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


DECLARE @TablaBBDD AS TABLE (ID  INT IDENTITY(1,1),NombreBBDD NVARCHAR(255))

INSERT INTO @TablaBBDD
SELECT name FROM sys.databases 

DECLARE @Conteo AS INT = (SELECT COUNT('') AS Conteo FROM @TablaBBDD)

DECLARE @NombreBBDD AS NVARCHAR(255)
DECLARE  @ConsultaSQL NVARCHAR(MAX)
DECLARE @TablaResultados AS TABLE (NombreBBDD NVARCHAR(255),Vista NVARCHAR(255))


WHILE @Conteo > 0
	BEGIN
		SET @NombreBBDD = (Select NombreBBDD FROM @TablaBBDD WHERE ID = @Conteo)

		IF HAS_DBACCESS(@NombreBBDD)=1
			BEGIN

		SET @ConsultaSQL = (SELECT 
							'SELECT '''+@NombreBBDD+''' AS NombreBBDD,v.name '+
							'FROM ['+@NombreBBDD+'].sys.views v '+
							'WHERE v.name LIKE ''%'+@Busqueda+'%'''
								
								) --Fin Consulta
			INSERT INTO @TablaResultados
			EXEC sp_executesql @ConsultaSQL
			END --Fin Condicion accesp
		SET @Conteo = @Conteo-1

	END

	SELECT * FROM @TablaResultados

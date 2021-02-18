

DECLARE @TipoCampoBuscar AS NVARCHAR(100) = 'char' --ESCRIBIR SOBRE QUE TIPO DE CAMPOS BUSCAR 
DECLARE  @ValorBuscar AS  NVARCHAR(100) = 'RETENIDO' --ESCRIBIR AQUI EL VALOR A BUSCAR


--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--LOCALIZAMOS TODAS LAS TABLAS QUE TIENEN ALGUN REGISTRO
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DECLARE @TablaTablas AS TABLE (Id INT IDENTITY(1,1), NombreTabla NVARCHAR(255))
INSERT INTO @TablaTablas (NombreTabla)
SELECT name FROM sys.tables 

DECLARE @ConteoTablas INT = (SELECT COUNT('') AS Conteo FROM @TablaTablas)

DECLARE @ConsultaSQL AS NVARCHAR(4000),@NombreTabla AS NVARCHAR(255)

DECLARE @TablaResultado AS TABLE (Id INT IDENTITY(1,1),Conteo  INT,NombreTabla NVARCHAR(255))

	DECLARE @TablaFinal AS TABLE (Id INT IDENTITY(1,1),NombreCampo NVARCHAR(255),NombreTabla NVARCHAR(255))
	INSERT INTO @TablaFinal ( NombreCampo,NombreTabla)

	SELECT c.name,t.name
	FROM  sys.tables t 
	INNER JOIN sys.all_columns c ON c.object_id = t.object_id
	WHERE TYPE_NAME(c.user_type_id) LIKE '%'+@TipoCampoBuscar+'%'
	--ORDER BY Conteo DESC

	
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--LOCALIZAMOS SI HAY VALORES INTERESANTES

SET @ConteoTablas = (SELECT COUNT('') AS CONTEO FROM @TablaFinal)

DECLARE @NombreCampo AS NVARCHAR(255)
CREATE TABLE ##TablaResultados (Id INT IDENTITY(1,1),ValorEncontrado NVARCHAR(MAX),CampoEncontrado NVARCHAR(255),TablaEncontrada  NVARCHAR(255))

WHILE @ConteoTablas > 0
	BEGIN
	SET @NombreCampo = (SELECT NombreCampo FROM @TablaFinal WHERE Id = @ConteoTablas)
	SET @NombreTabla = (SELECT NombreTabla FROM @TablaFinal WHERE Id = @ConteoTablas)

	SET @ConsultaSQL = (SELECT 
						'SELECT TOP 1 ''['+@NombreCampo+']'' AS ValorEncontrado,''['+@NombreCampo+']'' AS CampoLocalizado,''['+@NombreTabla+']'' AS TablaLocalizada '+
						'FROM dbo.['+@NombreTabla+']  WITH (NOLOCK) '+
						'WHERE ['+@NombreCampo+'] LIKE ''%'+@ValorBuscar+'%'' '
						)
			INSERT INTO ##TablaResultados (ValorEncontrado,CampoEncontrado,TablaEncontrada)			
		EXEC sys.sp_executesql @ConsultaSQL
	SET @ConteoTablas = @ConteoTablas-1

	END

	SELECT ValorEncontrado,CampoEncontrado,TablaEncontrada
	FROM --DROP TABLE 
	##TablaResultados 
	GROUP BY ValorEncontrado,CampoEncontrado,TablaEncontrada


CREATE PROCEDURE dbo.pa_ControlErroresCampos
@Tabla VARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;
--DECLARE @Tabla VARCHAR(255) = 'TB_Clientes'
	DECLARE @Campos AS VARCHAR(MAX)
	IF NOT EXISTS (SELECT * FROM tempdb.sys.tables WHERE name = '##'+@Tabla+'_ControlErrores')
	BEGIN
		SET @Campos = (SELECT STUFF((
			SELECT ','+c.name+' NVARCHAR(4000)'
			FROM sys.tables t
			INNER JOIN sys.all_columns c ON t.object_id = c.object_id
			WHERE t.name = @Tabla
			FOR XML PATH('')),1,1, ''))
		EXEC ('CREATE TABLE ##'+@Tabla+'_ControlErrores ('+@Campos+')')
	END
	
	IF EXISTS (SELECT * FROM tempdb.sys.tables WHERE name = '##Tabla_Control')
	EXEC ('DROP TABLE ##Tabla_Control')
	EXEC ('SELECT * INTO ##Tabla_Control FROM dbo.'+@Tabla)

	DECLARE @TablaResultados AS TABLE (Id INT IDENTITY(1,1),NombreCampo VARCHAR(255),Error NVARCHAR(4000))
	INSERT INTO @TablaResultados (NombreCampo)
	SELECT c.name
	FROM sys.tables t
	INNER JOIN sys.all_columns c ON t.object_id = c.object_id
	WHERE t.name = @Tabla
	AND c.is_identity = 0
	DECLARE @Conteo AS INT = @@ROWCOUNT
	DECLARE @NombreCampo AS VARCHAR(255)
	WHILE @Conteo > 0
		BEGIN
			SELECT @NombreCampo = NombreCampo
			FROM @TablaResultados 
			WHERE Id = @Conteo

			BEGIN TRY
				EXEC ('INSERT INTO ##Tabla_Control(['+@NombreCampo+'])
				SELECT ['+@NombreCampo+']
				FROM ##'+@Tabla+'_ControlErrores')
			END TRY
			BEGIN CATCH
				UPDATE @TablaResultados
				SET Error = ERROR_MESSAGE()
				WHERE Id = @Conteo
			END CATCH
			SET @Conteo = @Conteo-1
		END

	SET @Conteo = (SELECT COUNT('')
					FROM @TablaResultados
					WHERE Error IS NOT NULL)
	IF @Conteo > 0
		BEGIN
			
			EXEC ('DROP TABLE ##'+@Tabla+'_ControlErrores')
			SELECT NombreCampo,Error
			FROM @TablaResultados
			WHERE Error IS NOT NULL 
			
		END
	ELSE
		BEGIN
		
			PRINT N'No se detectan errores de truncamiento'+CHAR(10)+CHAR(13)
			+'Inserta Mismos Valores en ##'+@Tabla+'_ControlErrores'+CHAR(10)+CHAR(13)
			+'Y hacer EXEC dbo.ControlErroresCampos '''+@Tabla+''' '
		END
	EXEC ('DROP TABLE ##Tabla_Control')
END

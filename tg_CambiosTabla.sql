ALTER TRIGGER dbo.tg_Cambios ON dbo.TB_Clientes
	AFTER INSERT,DELETE,UPDATE
AS 
	BEGIN
		SET NOCOUNT ON
		--PARA OBTENER MAS DE UN REGISTRO
		DECLARE @TablaId AS TABLE (IdTabla INT IDENTITY(1,1),Id INT,Accion INT)
		INSERT INTO @TablaId (Id,Accion)
		SELECT ISNULL(d.CodCliente,i.CodCliente) AS Id
		,CASE WHEN d.CodCliente IS NOT NULL AND i.CodCliente IS NOT NULL THEN 1 --UPDATE
				WHEN d.CodCliente IS NOT NULL THEN 2 --DELETE
				ELSE 3 --INSERTED
			END
		FROM DELETED AS d
		FULL JOIN INSERTED AS i ON d.CodCliente=i.CodCliente
		DECLARE @Conteo AS INT= @@ROWCOUNT
	
		DECLARE @Accion INT = (SELECT Accion FROM @TablaId GROUP BY Accion)
	
		DECLARE @Id INT 
		IF ISNULL(@Accion,0)>0
			WHILE @Conteo > 0 
				BEGIN

					SELECT @Id = Id
					FROM @TablaId
					WHERE IdTabla = @Conteo

					INSERT INTO dbo.LOG_Cambios_TB_Clientes (CodCliente,Inserción,Modificación,Borrado)
					SELECT @Id
					,CASE WHEN @Accion = 3 THEN 1 ELSE 0 END
					,CASE WHEN @Accion = 1 THEN 1 ELSE 0 END
					,CASE WHEN @Accion = 2 THEN 1 ELSE 0 END

					SET @Conteo = @Conteo -1
				END
	END
	/*

	CREATE TABLE dbo.LOG_Cambios_TB_Clientes (IdCambio INT IDENTITY(1,1),FechaCambio DATETIME DEFAULT GETDATE(),UsuarioCambio VARCHAR(100) DEFAULT SYSTEM_USER,CodCliente INT,Inserción BIT,Modificación BIT,Borrado BIT)

	*/

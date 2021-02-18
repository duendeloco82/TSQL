

--DROP TABLE ##GruposWindows
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--EL USUARIO QUE LO EJECUTA OBTENDRÁ LA SITUACIÓN DE LOS PERMISOS EN TODAS LAS BBDD DEL SERVIDOR EN QUE SE ENCUENTRA
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--VARIABLES
DECLARE @FechaActual AS DATETIME SET @FechaActual= Switchoffset(CONVERT(datetimeoffset,GETUTCDATE()),'+02:00')
DECLARE @UsuariosABuscar AS NVARCHAR(500)
SET @UsuariosABuscar =  SYSTEM_USER --'SAREB\srv_dataq_pre'--Escribir aqui los usuarios a buscar (sin el dominio, nombre a secas) 

--CREAMOS LAS TABLAS GLOBALES QUE USAREMOS
--TablaUsuarios --se le insertará en función de la BBDD en que se encuentre
DECLARE @TablaUsuarios AS TABLE (Id INT IDENTITY(1,1)
								,Usuario NVARCHAR(150)
								,BBDD NVARCHAR(150)
								)
--Es la tabla Maestra que recogerá todos los datos finalizado el proceso
DECLARE @TablaPermisosUsuarios AS TABLE (Id INT IDENTITY(1,1)
										,Usuario NVARCHAR(255)
										,DescripcionPermisos NVARCHAR(4000)
										,BBDD NVARCHAR(150),Servidor NVARCHAR(100) DEFAULT @@SERVERNAME
										,IpServidor NVARCHAR(40) DEFAULT CAST(CONNECTIONPROPERTY('local_net_address') AS NVARCHAR(40))) 

--Recoge los posibles roles existentes, ya se le asigna los valores desde el sistema
DECLARE @TablaRoles AS TABLE (Id INT IDENTITY(1,1)
							,NombreRol NVARCHAR(150))
INSERT INTO @TablaRoles (NombreRol) SELECT name FROM sys.database_principals WHERE name LIKE 'db_%'

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VARIABLES PARA BUCLES--

--CONTEOS
--Usuarios
DECLARE @ConteoUsuarios AS INT DECLARE @MaxConteoUsuarios AS INT
--Bases de datos
DECLARE @ConteoBBDD AS INT DECLARE @MaxConteoBBDD AS INT
	
--DATOS
DECLARE @NombreUsuario AS NVARCHAR(500)
DECLARE @NombreBBDD AS NVARCHAR(500)
DECLARE @NombreRol AS NVARCHAR(500)

--MARCADORES
DECLARE @AccesoBBDD AS INT --si es 1 es accesible por el usuario --si es 2 no es accesible

	--%%%%%%%%%%%%%%%%% Variables SQL %%%%%%%%%%%%%%%%%%%%
--En tabla Usuarios
DECLARE @sqlInsercionUsuarios AS NVARCHAR(MAX)
--En tabla Roles
DECLARE @sqlrolesUsuario NVARCHAR(MAX)
--En tabla Permisos
DECLARE @SqlInsercionDatosTablaRoles AS NVARCHAR(MAX)
	--Variable Final --Consulta Final
DECLARE @SqlBusquedaPermisos NVARCHAR(4000)

DECLARE @sqlConsultaFinal AS NVARCHAR(4000)
DECLARE @sqlEjecucionFInal AS NVARCHAR(4000)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--PREVIO AL BUCLE 
--Se recogen lasBBDD existentes
DECLARE @TablaBBDD AS TABLE (Id INT IDENTITY(1,1)
							,NombreBBDD NVARCHAR(150))
INSERT INTO @TablaBBDD (NombreBBDD) SELECT REPLACE(REPLACE(name,'[',''),']','') FROM sys.databases --WHERE name  IN ('master')



--Se realiza el Conteo para  buclear 
SET @ConteoBBDD = (SELECT COUNT('') AS Conteo FROM @TablaBBDD)
SET @MaxConteoUsuarios = @ConteoBBDD
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--Inicia recorrido BUCLE

WHILE @ConteoBBDD > 0 --AQUI COMIENZA TODA LA PELICULA
	BEGIN 
		SET @NombreBBDD = (SELECT REPLACE(REPLACE(NombreBBDD,'[',''),']','') FROM @TablaBBDD WHERE Id = @ConteoBBDD)
		IF HAS_DBACCESS(@NombreBBDD) =1 
			BEGIN
				SET @NombreBBDD = '['+@NombreBBDD+']'
				--Obtencion Listado Usuarios
				--Tabla Usuarios para bucle
					IF @UsuariosABuscar = '' --Si se quiere mirar todos los usuarios de WINDOWS -- está para desarrollar
						BEGIN
							SET @sqlInsercionUsuarios = (SELECT 
							ISNULL(@sqlInsercionUsuarios,'')+
							'DELETE FROM @TablaUsuarios INSERT INTO @TablaUsuarios (Usuario,BBDD) '+
							'SELECT UPPER(name) AS Usuario,'''+@NombreBBDD+''' AS BBDD '+
							'FROM '+@NombreBBDD+'.sys.database_principals '+
							'WHERE 1=1 '+
							'AND type_desc = ''WINDOWS_USER'' '
							)
						END
					IF @UsuariosABuscar <> ''
						BEGIN
							SET @sqlInsercionUsuarios = (SELECT
							ISNULL(@sqlInsercionUsuarios,'')+
							'DELETE FROM @TablaUsuarios INSERT INTO @TablaUsuarios (Usuario,BBDD) '+
							'SELECT UPPER(name) AS Usuario,'''+@NombreBBDD+''' AS BBDD '+
							'FROM '+@NombreBBDD+'.sys.database_principals '+
							'WHERE 1=1 '+
							'AND name IN ('''+@UsuariosABuscar+''')'
							)
						END

				
							SET @NombreUsuario = @UsuariosABuscar
							--SELECT @NombreUsuario
									SET @SqlInsercionDatosTablaRoles = 
									(SELECT ISNULL(@SqlInsercionDatosTablaRoles,'')+
									'INSERT INTO @TablaPermisosUsuarios (Usuario,BBDD,Servidor,IpServidor) '+
									'SELECT '''+ISNULL(@NombreUsuario,'SIN USUARIO')+''', '''+ISNULL(@NombreBBDD,'SIN BBDD')+''' AS BBDD,@@SERVERNAME AS Servidor,CAST(CONNECTIONPROPERTY(''local_net_address'') AS NVARCHAR(40)) AS IpServidor  ')
							
							SET @sqlrolesUsuario = (SELECT ISNULL(@sqlrolesUsuario,'')+
													' UPDATE @TablaPermisosUsuarios '+
													'SET DescripcionPermisos = '+
													'ISNULL((SELECT STUFF((SELECT '','' + DP1.name COLLATE Modern_Spanish_CI_AS '+ 
													'FROM '+@NombreBBDD+'.sys.database_role_members AS DRM '+
													'RIGHT OUTER JOIN '+@NombreBBDD+'.sys.database_principals AS DP1  '+
														'ON DRM.role_principal_id = DP1.principal_id '+
													'LEFT OUTER JOIN '+@NombreBBDD+'.sys.database_principals AS DP2  '+
														'ON DRM.member_principal_id = DP2.principal_id '+
													'INNER JOIN @TablaPermisosUsuarios tr  '+
														'ON DP2.name = tr.Usuario COLLATE Modern_Spanish_CI_AS '+
													'WHERE 1=1 '+
													'AND tr.BBDD = '''+@NombreBBDD+''' '+
													'AND DP2.name IS NOT NULL '+
													'AND DP2.name = '''+ISNULL(@NombreUsuario,'')+''' '+
													'GROUP BY DP1.name '+ 
													'FOR XML PATH ('''')), 1, 1, '''')),''DESCONOCIDO, mínimo permisos lectura'') '+
													'WHERE BBDD = '''+@NombreBBDD+''' '+
													' AND Usuario = '''+ISNULL(@NombreUsuario,'')+''' '
													)

				END --Fin condicion si BBDD es accesible por el usuario que ejecuta
			IF HAS_DBACCESS(@NombreBBDD) =0
				BEGIN
					INSERT INTO @TablaPermisosUsuarios (Usuario,DescripcionPermisos,BBDD)
					SELECT UPPER(@UsuariosABuscar) AS Usuario,'NO TIENE ACCESO',@NombreBBDD
				END
		SET @ConteoBBDD = @ConteoBBDD -1

---EJECUCION

SET @sqlConsultaFinal = (SELECT 
						' SELECT Usuario,ISNULL(DescripcionPermisos,''DESCONOCIDO, mínimo permisos de lectura'') AS DescripcionPermisos,REPLACE(REPLACE(BBDD,''['',''''),'']'','''') AS BBDD,Servidor,IpServidor '+
						'FROM @TablaPermisosUsuarios '+
						'ORDER BY BBDD,DescripcionPermisos '
						)
SET @sqlInsercionUsuarios = (SELECT 
			' DECLARE @TablaUsuarios AS TABLE (Id INT IDENTITY(1,1), Usuario NVARCHAR(150),BBDD NVARCHAR(150)) '
			--ELSE ' ' END+
			+@sqlInsercionUsuarios) 
SET @SqlInsercionDatosTablaRoles = (SELECT 
			'DECLARE @TablaPermisosUsuarios AS TABLE (Id INT IDENTITY(1,1),Usuario NVARCHAR(255) '
		+',DescripcionPermisos NVARCHAR(4000),BBDD NVARCHAR(150),Servidor NVARCHAR(100) DEFAULT @@SERVERNAME,IpServidor NVARCHAR(40) DEFAULT CAST(CONNECTIONPROPERTY(''local_net_address'') AS NVARCHAR(40)))  '+
		@SqlInsercionDatosTablaRoles)
IF @SqlInsercionDatosTablaRoles IS NOT NULL
BEGIN
SET @sqlEjecucionFInal = (SELECT 'DECLARE @sqlInsercionUsuarios NVARCHAR(MAX) SET @sqlInsercionUsuarios = (SELECT '''+REPLACE(@sqlInsercionUsuarios,'''','''''')+''' )'+
								' DECLARE @SqlInsercionDatosTablaRoles NVARCHAR(MAX) SET @SqlInsercionDatosTablaRoles  = (SELECT '''+REPLACE(@SqlInsercionDatosTablaRoles,'''','''''')+ ''' )'+
								' DECLARE @sqlrolesUsuario NVARCHAR(MAX) SET @sqlrolesUsuario  = (SELECT '''+REPLACE(@sqlrolesUsuario,'''','''''')+ ''' )'+
								' DECLARE @sqlConsultaFinal NVARCHAR(MAX) SET @sqlConsultaFinal  = (SELECT '''+REPLACE(@sqlConsultaFinal,'''','''''')+ ''' )'+
								'DECLARE @CumulodeCosas NVARCHAR(MAX) SET @CumulodeCosas = (SELECT '+
								'@sqlInsercionUsuarios+@SqlInsercionDatosTablaRoles+@sqlrolesUsuario+@sqlConsultaFinal) '+
							' EXECUTE sys.sp_executesql @CumulodeCosas '+
							'WITH RESULT SETS '+
							'( '+
								'( '+
									'Usuario NVARCHAR(150) '+
									',DescripcionPermisos NVARCHAR(500)'+
									',BBDD NVARCHAR(150) '+
									',Servidor NVARCHAR(150) '+
									',IpServidor NVARCHAR(40) '+
								') '+
							');')
INSERT INTO @TablaPermisosUsuarios (Usuario,	DescripcionPermisos,	BBDD,	Servidor,IpServidor)
EXECUTE sys.sp_executesql @sqlEjecucionFInal

END

SET  @sqlInsercionUsuarios = '' SET @SqlInsercionDatosTablaRoles = '' SET @sqlrolesUsuario = ''		
	END --Fin Bucle BBDD 

------EJECUCIONES
--SELECT Usuario,DescripcionPermisos,REPLACE(REPLACE(BBDD,'[',''),']','')AS BBDD,Servidor ,IpServidor
--FROM @TablaPermisosUsuarios 
--ORDER BY BBDD,DescripcionPermisos

DELETE FROM @TablaPermisosUsuarios WHERE BBDD LIKE 'SnapShot%' OR  BBDD LIKE '%OLD'

DECLARE @TablaDatosProcesados AS TABLE (Id INT IDENTITY(1,1), BBDD NVARCHAR(255), Permisos NVARCHAR(500))
INSERT INTO @TablaDatosProcesados (BBDD)
SELECT REPLACE(REPLACE(BBDD,'[',''),']','')AS BBDD
FROM @TablaPermisosUsuarios
WHERE DescripcionPermisos <> 'NO TIENE ACCESO'
--*
--CREATE TABLE ##GruposWindows (Id INT IDENTITY(1,1),BBDD NVARCHAR(500),NombreGrupo NVARCHAR(500), Permisos NVARCHAR(500),Acceso INT DEFAULT 0)
--*
DECLARE @GruposWindows AS TABLE (Id INT IDENTITY(1,1),BBDD NVARCHAR(500),NombreGrupo NVARCHAR(500), Permisos NVARCHAR(500),Acceso INT DEFAULT 0) 
--* Nuevo

--SELECT * FROM @TablaDatosProcesados
--Variables Bucle
DECLARE @SqlConsultaFinal2 AS NVARCHAR(MAX) DECLARE @SqlSelectFinal AS NVARCHAR(MAX)
DECLARE @SqlConsultaProceso NVARCHAR(MAX) DECLARE @SqlActualizacionGrupos AS NVARCHAR(MAX)
SET @ConteoBBDD = (SELECT COUNT('') AS Conteo FROM @TablaDatosProcesados) --para produccion
--SET @ConteoBBDD = (SELECT COUNT('') AS Conteo FROM @TablaDatosProcesados WHERE BBDD LIKE  '%ATENEA%') --like para pruebas

--SELECT * FROM @TablaDatosProcesados


WHILE @ConteoBBDD > 0
	BEGIN 
	SET @NombreBBDD = (SELECT BBDD FROM @TablaDatosProcesados WHERE Id = @ConteoBBDD)
	--Grupos de la BBDD
	------------------------------------------------------------
	SET @SqlConsultaProceso = (SELECT 
	'DECLARE @GruposWindows AS TABLE (Id INT IDENTITY(1,1)'+ --nou
	',BBDD NVARCHAR(500),NombreGrupo NVARCHAR(500), Permisos NVARCHAR(500),Acceso INT DEFAULT 0) '+ --nou
	'INSERT INTO @GruposWindows (BBDD,NombreGrupo) '+ --nou
	--'INSERT INTO ##GruposWindows (BBDD,NombreGrupo) '+ --old
	'SELECT '''+@NombreBBDD+''' AS BBDD,name FROM ['+@NombreBBDD+'].sys.server_principals WHERE Type_desc IN (''WINDOWS_GROUP'') '+
	'UNION SELECT '''+@NombreBBDD+''' ,name COLLATE Modern_Spanish_CI_AS FROM ['+@NombreBBDD+'].sys.sysusers s WHERE s.name NOT LIKE ''db_%''')
	------------------------------------------------------------
	--EXEC sys.sp_executesql @SqlConsultaProceso --old

--ACTUALIZACION PERMISOS ORIGEN GRUPOS 
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SET @SqlActualizacionGrupos = (SELECT 
									--Variables para bucle
								'DECLARE @ConteoGrupos INT '+
								'DECLARE @NombreGrupo AS NVARCHAR(500) '+
								'DECLARE @Permisos AS NVARCHAR(500) '+
								'SET @ConteoGrupos = (SELECT COUNT('''') AS Conteo FROM @GruposWindows) '+
								'WHILE @ConteoGrupos > 0 '+
									'BEGIN '+
									'SET @NombreGrupo = (SELECT NombreGrupo FROM @GruposWindows '+ --change
															'WHERE Id = @ConteoGrupos) '+
									'IF IS_MEMBER(@NombreGrupo) = 1 '+ --Evalua si está en el grupo
										'BEGIN '+ 
	
										'SET @Permisos = ISNULL((SELECT STUFF((SELECT '','' +s.name '+
														'FROM ['+@NombreBBDD+'].sys.sysusers s '+
														'INNER JOIN ['+@NombreBBDD+'].sys.database_role_members m ON s.uid = m.role_principal_id '+
														'LEFT JOIN (SELECT s.name,m.* FROM ['+@NombreBBDD+'].sys.database_role_members m '+
														'INNER JOIN ['+@NombreBBDD+'].sys.sysusers s ON s.uid = m.member_principal_id) AS x ON m.member_principal_id = x.member_principal_id '+
														'WHERE x.name = @NombreGrupo '+
														'GROUP BY s.name '+
														'FOR XML PATH ('''')), 1, 1,'''')),'''') '+
										--Actualizacion tabla grupos
										'UPDATE @GruposWindows  '+ --Change
										'SET Permisos = @Permisos '+
										'WHERE Id = @ConteoGrupos '+

										'END '+ --Fin Condicion está en el grupo
									'SET @ConteoGrupos = @ConteoGrupos -1 '+
								'END ' --Fin Bucle Grupos '
								) --Fin Variable
	SET @SqlSelectFinal = (SELECT ' SELECT '+
							'BBDD,NombreGrupo, Permisos,Acceso '+
							'FROM @GruposWindows ')
	--SELECT @SqlActualizacionGrupos
	SET @SqlConsultaFinal2 = (@SqlConsultaProceso + @SqlActualizacionGrupos+@SqlSelectFinal)
	--EXEC sys.sp_executesql @SqlActualizacionGrupos --old
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--SELECT @SqlConsultaFinal2
INSERT INTO @GruposWindows (BBDD,NombreGrupo, Permisos,Acceso) 
EXEC sys.sp_executesql @SqlConsultaFinal2


	--Actualizacion Tabla Proceso
	------------------------------------------------------------
	UPDATE u
	SET DescripcionPermisos = ISNULL(s.Permisos,'DESCONOCIDO, mínimo permisos de Lectura.') --COLLATE Modern_Spanish_CI_AS
	FROM @TablaPermisosUsuarios u
	INNER JOIN (SELECT (SELECT STUFF((SELECT ',' +Permisos  FROM @GruposWindows WHERE ISNULL(Permisos,'') <> '' GROUP BY Permisos    FOR XML PATH ('')), 1, 1,'')) AS Permisos,BBDD FROM @GruposWindows GROUP BY BBDD ) s ON u.BBDD = s.BBDD COLLATE Modern_Spanish_CI_AS
	WHERE u.DescripcionPermisos LIKE 'DESCONOCIDO%' OR u.DescripcionPermisos IS NULL

	--TRUNCATE TABLE ##GruposWindows --Necesario para seguir bucleando --old
	------------------------------------------------------------

	SET @ConteoBBDD = @ConteoBBDD -1
	
	END --Fin Bucle


	SELECT * 
	FROM @TablaPermisosUsuarios 
	ORDER BY BBDD
	--DROP TABLE ##GruposWindows --old


CREATE FUNCTION [dbo].[fn_Capitalize]
(
@Palabra AS NVARCHAR(255)
)
RETURNS NVARCHAR (255)
AS
BEGIN
	
	WHILE CHARINDEX('  ',@Palabra)>0 --Esto es por si hay mas de un espacio entre las palabras
		BEGIN 
			SET @Palabra = REPLACE(LTRIM(RTRIM(@Palabra)),'  ',' ')
		END
	DECLARE @PalabraOriginal AS NVARCHAR(255) = @Palabra
	DECLARE @Espacios AS INT = (LEN(@Palabra)-LEN(REPLACE(@Palabra,' ','')))+1

	DECLARE @Resultado AS NVARCHAR(255) = ''

	WHILE @Espacios >0
		BEGIN

			SET @Resultado = @Resultado+' '+LEFT(UPPER(@Palabra),1)
			SET @Resultado = @Resultado+LOWER(SUBSTRING(LTRIM(RTRIM(@Palabra)),2,CASE WHEN CHARINDEX(' ',LTRIM(RTRIM(@Palabra)))=0 THEN 255 ELSE CHARINDEX(' ',LTRIM(RTRIM(@Palabra)))-1 END))
			SET @Resultado=LTRIM(RTRIM(@Resultado))
			SET @Palabra = LTRIM(RTRIM(SUBSTRING(@PalabraOriginal,CHARINDEX(@Resultado,@PalabraOriginal)+LEN(@Resultado),LEN(@PalabraOriginal))))
			SET @Espacios = @Espacios -1

		END --FIN BUCLE

	RETURN @Resultado

END

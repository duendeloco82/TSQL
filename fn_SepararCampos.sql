CREATE FUNCTION [dbo].[fn_SepararCampos]
(
@Texto AS NVARCHAR(4000)
,@Separador AS NVARCHAR(5)
,@Posicion AS INT
)
RETURNS NVARCHAR (255)
AS
BEGIN

DECLARE @SeparadorControl AS NVARCHAR(5)=@Separador

DECLARE @CampoObtenido AS NVARCHAR(255)

WHILE @Posicion>0
	BEGIN

		SET @CampoObtenido = SUBSTRING(@Texto,1,CASE WHEN CHARINDEX(@SeparadorControl,@Texto)=0 THEN LEN(REPLACE(@Texto,@SeparadorControl,'')) ELSE CHARINDEX(@SeparadorControl,@Texto) END)

		SET @Texto = SUBSTRING(@Texto,LEN(@CampoObtenido)+LEN(@SeparadorControl),CASE WHEN LEN(@Texto)=0 THEN LEN(REPLACE(@Texto,@SeparadorControl,'')) ELSE LEN(@Texto) END)

		SET @Posicion = @Posicion-1
	END

	RETURN REPLACE(@CampoObtenido,@SeparadorControl,'') 


END

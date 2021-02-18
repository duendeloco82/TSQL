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

		SET @CampoObtenido = SUBSTRING(@Texto,1,CASE WHEN CHARINDEX(@SeparadorControl,@Texto)=0 THEN (LEN('['+REPLACE(@Texto,@SeparadorControl,'')+']')-2) ELSE CHARINDEX(@SeparadorControl,@Texto)-1 END)

		SET @Texto = SUBSTRING(@Texto,(LEN('['+@CampoObtenido+']')-2)+(LEN('['+@SeparadorControl+']')-2)+1,CASE WHEN (LEN('['+@Texto+']')-2)=0 THEN (LEN('['+REPLACE(@Texto,@SeparadorControl,'')+']')-2) ELSE (LEN('['+@Texto+']')-2) END)

		SELECT @CampoObtenido,@Texto
		SET @Posicion = @Posicion-1
	END

	RETURN REPLACE(@CampoObtenido,@SeparadorControl,'') 


END

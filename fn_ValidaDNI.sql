CREATE FUNCTION [dbo].[fn_ValidarNIF]
(@DNI NVARCHAR(99))
RETURNS NVARCHAR(255) 
BEGIN

	DECLARE @ResultadoLetra NVARCHAR(1),@ResultadoFinal NVARCHAR(255)
	IF LEN(@DNI) NOT BETWEEN 8 AND 9 --CANTIDAD CARACTERES
		BEGIN SET @ResultadoFinal = 'ERROR - Número caracteres incorrecto (debe ser entre 8 y 9).' END
	

	ELSE IF ISNUMERIC(LEFT(@DNI,8))=0 --SOLO NUMEROS 8 primeros DIGITOS
		BEGIN SET  @ResultadoFinal = 'ERROR - Debe contener únicamente números en los 8 primeros caracteres.' END

		--= (@NumeroDNI % 23)
	ELSE 
		BEGIN
			
			SET @ResultadoLetra = SUBSTRING('TRWAGMYFPDXBNJZSQVHLCKE', LEFT(@DNI,8) % 23 + 1, 1)

			IF ISNUMERIC(RIGHT(@DNI,1))=0 
				BEGIN 
					IF RIGHT(@DNI,1) = @ResultadoLetra
						BEGIN SET  @ResultadoFinal = @DNI END
					ELSE BEGIN SET  @ResultadoFinal =  'ERROR - La letra escrita no corresponde con el número del DNI.' END
				END
			ELSE 
				BEGIN 
					SET @ResultadoFinal =LEFT(@DNI,8) +@ResultadoLetra
				END

		END --FIN CONDICION PRINCIPAL VALIDACION DNI CON ELSE

	RETURN @ResultadoFinal
	
END

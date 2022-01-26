CREATE FUNCTION dbo.fn_UltimoDiaSemana
(
@FechaMomento AS DATETIME
,@DiaSemana AS INT
)
RETURNS DATETIME
AS
BEGIN

	IF DATEPART(WEEKDAY,@FechaMomento) < @DiaSemana
	SET @FechaMomento = DATEADD(DAY,-7,@FechaMomento)
	
	DECLARE @FechaResultado AS DATETIME =DATEADD(WEEKDAY,@DiaSemana-DATEPART(WEEKDAY,@FechaMomento),@FechaMomento)

	RETURN @FechaResultado

END

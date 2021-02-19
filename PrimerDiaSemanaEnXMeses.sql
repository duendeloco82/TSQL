SET LANGUAGE SPANISH

DECLARE @FechaActual AS DATETIME = GETDATE()
DECLARE @IncrementoMensual AS INT = 2,@PrimerDiaSemana AS INT =4,@DiasSemanas AS INT = 7
DECLARE @FechaModificada AS DATETIME
SET @FechaModificada = (
SELECT CAST('01/'+RIGHT('00'+CAST(DATEPART(MONTH,@FechaActual)+@IncrementoMensual  AS NVARCHAR(2)),2)+'/'+CAST(DATEPART(YEAR,@FechaActual) AS NVARCHAR(4)) AS DATE)
)
DECLARE @Incremento AS INT = (
SELECT CASE WHEN DATEPART(WEEKDAY,@FechaModificada) < @PrimerDiaSemana THEN @PrimerDiaSemana-DATEPART(WEEKDAY,@FechaModificada)
		WHEN DATEPART(WEEKDAY,@FechaModificada) > @PrimerDiaSemana THEN @DiasSemanas+@PrimerDiaSemana-DATEPART(WEEKDAY,@FechaModificada)
		ELSE 0 END)

SELECT DATEADD(DAY,@Incremento,@FechaModificada)

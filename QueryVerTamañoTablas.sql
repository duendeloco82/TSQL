
  SELECT t.name AS NombreTabla,
  s.name AS Esquema,
  p.rows AS NumFilas,
  SUM(a.total_pages)*8 EspacioTotal_KB,
  SUM(a.used_pages)*8 AS EspacioUsado_KB,
  (SUM(a.total_pages)-SUM(a.used_pages))*8 AS EspacioNoUsado_KB
  FROM sys.tables t
  INNER JOIN sys.indexes i ON t.object_id = i.object_id
  INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
  INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
  LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
  WHERE t.is_ms_shipped = 0
  AND i.object_id > 255
  GROUP BY t.name,s.name,p.rows
  ORDER BY EspacioUsado_KB DESC

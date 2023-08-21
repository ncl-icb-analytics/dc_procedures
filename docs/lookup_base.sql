SELECT d.Year, d.Fin_month, d.eID, d.id_pro FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY lu.eID ORDER BY priority) AS row_num
FROM [Data_Lab_NCL].[dbo].[apc_day_prolu] lu

INNER JOIN [Data_Lab_NCL].[dbo].[apc_day_procedures] pro
ON lu.id_pro = pro.id
) d
WHERE d.row_num = 1
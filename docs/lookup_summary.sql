SELECT a.Year, a.Fin_Month, a.id, a.name, a.speciality_area, COUNT(1) AS Count

FROM (
	SELECT d.Year, d.Fin_month, d.eID, d.id, d.name, d.speciality_area 
	FROM (
		SELECT *, ROW_NUMBER() OVER(PARTITION BY lu.eID ORDER BY priority) AS row_num
		FROM [Data_Lab_NCL].[dbo].[apc_day_prolu] lu

		INNER JOIN [Data_Lab_NCL].[dbo].[apc_day_procedures] pro
		ON lu.id_pro = pro.id
	) d
	WHERE d.row_num = 1
) a

GROUP BY a.Year, a.Fin_month, a.name, a.speciality_area, a.id

ORDER BY a.name ASC
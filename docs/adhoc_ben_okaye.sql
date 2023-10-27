SELECT Year, Fin_month,
	CASE
		WHEN Fin_month = 1 THEN 'Jan'
		WHEN Fin_month = 2 THEN 'Feb'
		WHEN Fin_month = 3 THEN 'Mar'
		WHEN Fin_month = 4 THEN 'Apr'
		WHEN Fin_month = 5 THEN 'May'
		WHEN Fin_month = 6 THEN 'Jun'
		WHEN Fin_month = 7 THEN 'Jul'
		WHEN Fin_month = 8 THEN 'Aug'
		WHEN Fin_month = 9 THEN 'Sep'
		WHEN Fin_month = 10 THEN 'Oct'
		WHEN Fin_month = 11 THEN 'Nov'
		WHEN Fin_month = 12 THEN 'Dec'
	END AS month_mmm,
	pro_name, speciality_area, benchmark,
	shorthand, 
	EL, DC,
	CAST(COALESCE(DC, 0) AS FLOAT)/COALESCE(DC+EL, COALESCE(DC, 1)) AS [Day Case Rate]  
FROM (
	SELECT Year, Fin_month, POD, ProviderCode, 
	pro_name, speciality_area, benchmark,
	COUNT(1) AS count
	FROM (
		--Patient level data
		SELECT d.Year, d.Fin_month, fs.POD, fs.ProviderCode, 
			   d.speciality_area, d.name AS pro_name, d.benchmark
		--Sub-query to apply priority to results
		FROM (
			SELECT *, ROW_NUMBER() OVER(PARTITION BY lu.eID ORDER BY priority) AS row_num

			--Lookup Table
			FROM [Data_Lab_NCL].[dbo].[apc_day_prolu] lu

			--Procedure Table
			INNER JOIN [Data_Lab_NCL].[dbo].[apc_day_procedures] pro
			ON lu.id_pro = pro.id
		) d

		--Get provider
		INNER JOIN [NCL].[dbo].[Maindata_FasterSUS_IP_all_93c] fs
		ON d.eID = fs.eID

		WHERE d.row_num = 1
		AND d.HVLC = 1
	) pld

	GROUP BY Year, Fin_month, POD, ProviderCode, pro_name, speciality_area, benchmark
) agg

--Org information
INNER JOIN [Data_Lab_NCL].[dbo].[wf_ds_nclorgs] org
ON agg.[ProviderCode] = org.org_code

PIVOT (
	AVG(count) FOR
	[POD] IN ([EL], [DC])
) pvt

WHERE pvt.ncl_provider = 1

	

--Common Expression Table for bulk of processing
WITH cte (
	[Year], [Fin_Month], [datapoint], [Qtr],
	[org_code], [org_name], [shorthand],
	[POD], [dc], [el], [los_01_el], [activity],
	[id_pro], [procedure_speciality], [procedure_name], [procedure_benchmark], [hvlc],
	[spell.admission.intended_management], [intended],
	[BedDays], [independent_care]
) 
AS (

	SELECT			
		[Year], [Fin_Month], 
		CONCAT(Year, '_', [Fin_Month]) AS [datapoint],
		CONCAT('Q', (([Fin_Month] - 1) / 3) + 1) AS [Qtr],
		-- For Org name
		[org_code], [org_name], [shorthand],
		-- For POD category AND Booked Type
		[POD],
		SUM(dc_count) AS [dc],
		SUM(el_count) AS [el],
		SUM(los_01_el_count) AS [los_01_el],
		COUNT(1) AS [activity],
		-- Procedure
		[id_pro], [procedure_speciality],
		CASE WHEN [procedure_name] IS NULL THEN 'Other' ELSE [procedure_name] END AS [procedure_name],
		[procedure_benchmark], [hvlc],
		--In Spell?
		[spell.admission.intended_management],
		CASE 
			WHEN [spell.admission.intended_management] = 1 THEN 'EL'
			WHEN [spell.admission.intended_management] = 2 THEN 'DC'
			ELSE 'Other'
		END AS [intended],
		-- For LOS
		[BedDays], 
		CASE WHEN [shorthand] IN ('BMIC', 'HEN', 'KING', 'HIGH') THEN 1 ELSE 0 END AS [independent_care]
				
	FROM (
		--DISTINCT to remove duplicates from the SUS dataset
		SELECT DISTINCT
			ip.[eID],
			ip.[Fin_Month], ip.[Year],
			-- Both used and for Adult/Paed
			ip.[Age],
			-- For Org name
			ip.[ProviderCode] AS [org_code],
			org.[org_name], org.[shorthand],
			-- For POD category AND Booked Type
			ip.[POD],
			CASE WHEN ip.[POD] = 'DC' THEN 1 ELSE 0 END AS [dc_count],
			CASE WHEN ip.[POD] = 'EL' THEN 1 ELSE 0 END AS [el_count],
			CASE WHEN ip.[POD] = 'EL' AND ip.[BedDays] < 2 THEN 1 ELSE 0 END AS [los_01_el_count],
			-- Procedure
			lu.[id_pro],
			pro.name AS [procedure_name],
			pro.speciality_area AS [procedure_speciality],
			pro.benchmark AS [procedure_benchmark],
			pro.[HVLC] AS [hvlc],
			--In Spell?
			fss.[spell.admission.intended_management],
			-- For LOS
			ip.[BedDays]
			

		FROM ncl.dbo.Maindata_FasterSUS_IP_all_93c ip

		--For extra info from main faster sus spell table
		INNER JOIN [Data_Store_SUS_Unified].[APC].[spell] fss
		ON ip.eID = fss.PRIMARYKEY_ID

		--For episode info (To get dominant episode)
		INNER JOIN [Data_Store_SUS_Unified].[APC].[spell.episodes] fsse
		ON ip.eID = fsse.PRIMARYKEY_ID
	
		--Procedure lookup
		INNER JOIN (
			SELECT d.Year, d.Fin_month, d.eID, d.id_pro 
			FROM (
				--For cases where procedure definitions overlap, take the one with the highest priority. Runs on the assumption there is no overlap between specialities
				SELECT *, ROW_NUMBER() OVER(PARTITION BY lu.eID ORDER BY priority) AS row_num
				FROM [Data_Lab_NCL].[dbo].[apc_day_prolu] lu

				INNER JOIN [Data_Lab_NCL].[dbo].[apc_day_procedures] pro
				ON lu.id_pro = pro.id
			) d
			WHERE d.row_num = 1
		) lu

		---Filtering on year and month is non-essential but increases performance
		ON ip.eID = lu.eID
		AND ip.Year = lu.Year
		AND ip.Fin_Month = lu.Fin_month

		--Procedure information
		LEFT JOIN [Data_Lab_NCL].[dbo].[apc_day_procedures] pro
		ON lu.id_pro = pro.id

		--Organisation information
		LEFT JOIN [Data_Lab_NCL].[dbo].[wf_ds_nclorgs] org
		--ON org.org_code = ip.ProviderCode
		--This works with the private care organisations but adds performance issues
		ON fss.[spell.commissioning.service_agreement.provider] LIKE org.org_code +'%'

		--Specify relevant organisations
		WHERE 
		(
			ip.ProviderCode IN ('RAP','RKE','RAN','RRV','RAL','RP6','RP4')
			OR
			--Requested by Andrew
			fss.[spell.commissioning.service_agreement.provider] IN ('NT451','NT421','NT416','NYW03','G3Q3Z')
		)

		--Filter on closed spells and the dominant episode
		AND fss.[spell.open_spell_indicator] = 0
		AND fsse.[dominant_episode_flag] = 1

	) agg

	GROUP BY		[Fin_Month], [Year],
					-- For Org name
					[org_code], [org_name], [shorthand],
					-- For POD category AND Booked Type
					[POD],
					-- Procedure
					[id_pro], [procedure_name],
					[procedure_speciality], [procedure_benchmark], [hvlc],
					--In Spell?
					[spell.admission.intended_management],
					-- For LOS
					[BedDays]
)


--Select for organisation level data
SELECT * FROM cte

UNION ALL

--Select for NCL aggregated data
SELECT 
	[Year], [Fin_Month], [datapoint], [Qtr],
	'X' AS [org_code],
	'agg_NCL' AS [org_name],
	'NCL' AS [shorthand],
	[POD], [dc], [el], [los_01_el], [activity],
	[id_pro], [procedure_speciality], [procedure_name], [procedure_benchmark], [hvlc],
	[spell.admission.intended_management], [intended],
	[BedDays], [independent_care]

FROM (
	SELECT 
		[Year], [Fin_Month], [datapoint], [Qtr],
		[POD], 
		SUM([dc]) AS [dc], 
		SUM([el]) AS [el], 
		SUM([los_01_el]) AS [los_01_el], 
		SUM([activity]) AS [activity],
		[id_pro], [procedure_speciality], [procedure_name], [procedure_benchmark], [hvlc],
		[spell.admission.intended_management], [intended],
		[BedDays], [independent_care]

	FROM cte

	WHERE org_code IN ('RAP','RKE','RAN','RRV','RAL','RP6','RP4')

	GROUP BY 
		[Year], [Fin_Month], [datapoint], [Qtr],
		[POD], 
		[id_pro], [procedure_speciality], [procedure_name], [procedure_benchmark], [hvlc],
		[spell.admission.intended_management], [intended],
		[BedDays], [independent_care]

) agg
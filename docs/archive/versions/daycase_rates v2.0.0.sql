--DISTINCT to rem
SELECT DISTINCT
			ip.[eID],
			ip.[Fin_Month], ip.[Year],
			-- Both used and for Adult/Paed
			ip.[Age],
			-- For Org name
			ip.[ProviderCode],
			-- For POD category AND Booked Type
			ip.[POD],
			-- Procedure
			lu.[id_pro],
			pro.[name] AS [procedure_name],
			pro.speciality_area AS [procedure_speciality],
			pro.benchmark AS [procedure_benchmark],
			pro.[HVLC] AS [hvlc],
			--In Spell?
			fss.[spell.admission.intended_management],
			CASE 
				WHEN fss.[spell.admission.intended_management] = 1 THEN 'EL'
				WHEN fss.[spell.admission.intended_management] = 2 THEN 'DC'
				ELSE 'Other'
			END AS [intended],
			-- For LOS
			ip.[BedDays],
			-- For NCL\Non-NCL
			ip.[CommissionerCode],
			CASE WHEN ip.[CommissionerCode] IN ('07M','07R','07X','08D','08H','93C') THEN 1 ELSE 0 END AS [commissioner_ncl],
			--Critical Care
			CASE 
			WHEN fssc.PRIMARYKEY_ID IS NULL THEN 0
			ELSE 1 
			END AS [Critical Care Flag]

FROM ncl.dbo.Maindata_FasterSUS_IP_all_93c ip

--For extra info from main faster sus spell table
INNER JOIN [Data_Store_SUS_Unified].[APC].[spell] fss
ON ip.eID = fss.PRIMARYKEY_ID

--For episode info (Unused? Maybe for filtering on episode_id = 1?)
INNER JOIN [Data_Store_SUS_Unified].[APC].[spell.episodes] fsse
ON ip.eID = fsse.PRIMARYKEY_ID

--Critical Care data
LEFT JOIN [Data_Store_SUS_Unified].[APC].[spell.critical_care_consolidated] fssc
ON ip.eID = fssc.PRIMARYKEY_ID

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
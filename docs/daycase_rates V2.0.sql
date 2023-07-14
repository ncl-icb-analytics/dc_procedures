SELECT 
	bd.[SK_EncounterID],
	bd.[dv_FinMonth] AS [fmonth], bd.[dv_FinYear] AS [fyear],
	-- Both used and for Adult/Paed
	CASE 
		WHEN bd.[Age_At_CDS_Activity_Date] <= 16 THEN 'Paediatric (0-16)' 
		WHEN bd.[Age_At_CDS_Activity_Date] > 16 THEN 'Adult (17 & above)'
		ELSE 'N/A'
	END AS [Adult/Paed],
	-- For Org name
	--Possibly do at a later stage when there are less rows (post group by)
	orgs.[org_code],
	orgs.[org_name],
	-- For POD category AND Booked Type
	pod.[pod] AS [point_of_delivery],
	CASE 
		WHEN bd.[Intended_Management] = 1 THEN 'EL'
		WHEN bd.[Intended_Management] = 2 THEN 'DC'
	ELSE 'Other'
	END AS [booked_as],
	-- For LOS
	CASE
		WHEN bd.[dv_LengthOfStay_Gross] = 0 THEN '0 day'
		WHEN bd.[dv_LengthOfStay_Gross] = 1 THEN '1 day'
		ELSE '>1 day'
	END AS [grouped_los],
	-- For NCL\Non-NCL
	CASE 
		WHEN left(bd.[Organisation_Code_Code_of_Commissioner], 3) IN ('07M','07R','07X','08D','08H','93C') Then 'NCL' 
		Else 'Non-NCL' 
	End as [NCL\Non-NCL],
	-- For Critical Care Flag

	CASE
		WHEN SK_EncounterID in (SELECT SK_EncounterID FROM [SUS].[IP].[EncounterCriticalCare_DateRange]) THEN 'Yes' 
		ELSE 'No' 
	END AS [Critical Care Flag]
	
FROM (
	--Base data query on SUS dataset to get relevant columns
	SELECT
		ip.SK_EncounterID,
		ip.[dv_FinMonth], ip.[dv_FinYear],
		-- Both used and for Adult/Paed
		ip.[Age_At_CDS_Activity_Date],
		-- For Org name
		ip.[Organisation_Code_Code_of_Provider],
		-- For POD category AND Booked Type
		ip.[Admission_Method_Hospital_Provider_Spell],
		ip.[Patient_Classification],
		ip.[Intended_Management],
		-- For LOS
		ip.[dv_LengthOfStay_Gross],
		-- For NCL\Non-NCL
		ip.[Organisation_Code_Code_of_Commissioner]


	FROM [SUS].[IP].[EncounterDenormalised_DateRange] ip
	--Filter on spells
	WHERE ip.dv_IsSpell = 1
	--Filter on NCL providers
	AND (
		LEFT(Organisation_Code_Code_of_Provider,3) IN ('RAP','RKE','RAN','RRV','RAL','RP6','RP4')
		OR
		--Requested by Andrew
		Organisation_Code_Code_of_Provider IN ('NT451','NT421','NT416','NYW03','G3Q3Z')
	)
	--Limit to recent fyears
	AND dv_FinYear IN ('2022/2023','2023/2024')
	--EL and DC admissions
	AND Admission_Method_Hospital_Provider_Spell IN ('11', '12', '13')
	--EL and DC
	AND Patient_Classification IN ('1','2') 
) AS bd

--Join on pod table to get POD
LEFT JOIN [Data_Lab_NCL].[dbo].[daycase_jake_podmap] pod
ON bd.Admission_Method_Hospital_Provider_Spell = pod.admission_method
AND bd.Patient_Classification = pod.patient_classification

--Join on orgs table to get org name
LEFT JOIN [Data_Lab_NCL].[dbo].[wf_ds_nclorgs] orgs
ON bd.[Organisation_Code_Code_of_Provider] = orgs.[org_code]
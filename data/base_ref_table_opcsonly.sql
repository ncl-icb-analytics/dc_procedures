-- Base of the reference table used in the procedures script
-- Outputs basic procedure identifying information
SELECT 
	Year, Fin_Month, org_code, Age, POD, tfc, main_spec,
	hospital_no,
	PRIMARYKEY_ID, EPISODES_ID
FROM (
	SELECT 
		fs.Year, fs.Fin_Month,
		fs.ProviderCode AS [org_code],
		fs.Age, fs.POD, 
		fs.SpecCode AS [tfc],
		fsse.[care_professional.main_specialty] AS [main_spec],
		fs.SLAM_HospitalNo AS [hospital_no],
		opcs.PRIMARYKEY_ID, opcs.EPISODES_ID, 
		code, 'opcs_' + CAST(OPCS_ID AS VARCHAR) AS OPCS_ID

	FROM [Data_Store_SUS_Unified].[APC].[spell.episodes.clinical_coding.procedure.opcs] opcs

	--To get hospital spell to join with fs table
	INNER JOIN [Data_Store_SUS_Unified].[APC].[spell] fss
	ON opcs.PRIMARYKEY_ID = fss.PRIMARYKEY_ID

	--Main row info
	LEFT JOIN [NCL].[dbo].[Maindata_FasterSUS_IP_all_93c] fs
	ON fs.SLAM_HospitalNo = fss.[spell.hospital_provider_spell_number]
	AND fs.ProviderCode = fss.[spell.commissioning.service_agreement.provider_derived]

	--Episode data
	LEFT JOIN [Data_Store_SUS_Unified].[APC].[spell.episodes] fsse
	ON opcs.PRIMARYKEY_ID = fsse.PRIMARYKEY_ID
	AND opcs.EPISODES_ID = fsse.EPISODES_ID

	WHERE OPCS_ID <= 12
	AND Year IS NOT NULL
	AND fsse.[spell.open_spell_indicator] = 0
	AND fsse.[dominant_episode_flag] = 1
	AND fs.SLAM_HospitalNo IS NOT NULL

) AS s
PIVOT (
	MAX(code)
	FOR OPCS_ID IN (
		opcs_1, opcs_2, opcs_3, opcs_4, opcs_5, opcs_6, opcs_7, opcs_8,
		opcs_9, opcs_10, opcs_11, opcs_12
	)
) AS unpvt

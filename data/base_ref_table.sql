-- Base of the reference table used in the procedures script
-- Outputs basic procedure identifying information
SELECT opcs.*, 
	CONCAT(opcs_1, opcs_2, opcs_3, opcs_4, opcs_5, opcs_6, opcs_7, opcs_8,
		opcs_9, opcs_10, opcs_11, opcs_12, opcs_13, opcs_14, opcs_15, opcs_16,
		opcs_17, opcs_18, opcs_19, opcs_20, opcs_21, opcs_22, opcs_23, opcs_24) AS opcs_all,

	icd_1, icd_2, icd_3, icd_4, icd_5, icd_6, icd_7, icd_8,
	icd_9, icd_10, icd_11, icd_12, icd_13, icd_14, icd_15, icd_16,
	icd_17, icd_18, icd_19, icd_20, icd_21, icd_22, icd_23, icd_24,

	CONCAT(icd_1, icd_2, icd_3, icd_4, icd_5, icd_6, icd_7, icd_8,
		icd_9, icd_10, icd_11, icd_12, icd_13, icd_14, icd_15, icd_16,
		icd_17, icd_18, icd_19, icd_20, icd_21, icd_22, icd_23, icd_24) AS icd_all
FROM (
	SELECT 
		Year, Fin_Month, Age, POD, tfc, main_spec,
		PRIMARYKEY_ID, EPISODES_ID,
		opcs_1, opcs_2, opcs_3, opcs_4, opcs_5, opcs_6, opcs_7, opcs_8,
		opcs_9, opcs_10, opcs_11, opcs_12, opcs_13, opcs_14, opcs_15, opcs_16,
		opcs_17, opcs_18, opcs_19, opcs_20, opcs_21, opcs_22, opcs_23, opcs_24
	FROM (
		SELECT 
			fs.Year, fs.Fin_Month,
			fs.Age, fs.POD, 
			fs.SpecCode AS [tfc], 
			fsse.[care_professional.main_specialty] AS [main_spec],
			opcs.PRIMARYKEY_ID, opcs.EPISODES_ID, 
			code, 'opcs_' + CAST(OPCS_ID AS VARCHAR) AS OPCS_ID
		FROM [Data_Store_SUS_Unified].[APC].[spell.episodes.clinical_coding.procedure.opcs] opcs

		LEFT JOIN [NCL].[dbo].[Maindata_FasterSUS_IP_all_93c] fs
		ON fs.eID = opcs.PRIMARYKEY_ID

		LEFT JOIN [Data_Store_SUS_Unified].[APC].[spell.episodes] fsse
		ON opcs.PRIMARYKEY_ID = fsse.PRIMARYKEY_ID
		AND opcs.EPISODES_ID = fsse.EPISODES_ID

		WHERE OPCS_ID <= 24
		AND Year IS NOT NULL
		AND fsse.[spell.open_spell_indicator] = 0
		AND fsse.[dominant_episode_flag] = 1

	) AS s
	PIVOT (
		MAX(code)
		FOR OPCS_ID IN (
			opcs_1, opcs_2, opcs_3, opcs_4, opcs_5, opcs_6, opcs_7, opcs_8,
			opcs_9, opcs_10, opcs_11, opcs_12, opcs_13, opcs_14, opcs_15, opcs_16,
			opcs_17, opcs_18, opcs_19, opcs_20, opcs_21, opcs_22, opcs_23, opcs_24
		)
	) AS unpvt
) opcs

LEFT JOIN (
	SELECT 
		Year, Fin_Month, Age, POD,
		PRIMARYKEY_ID, EPISODES_ID,
		icd_1, icd_2, icd_3, icd_4, icd_5, icd_6, icd_7, icd_8,
		icd_9, icd_10, icd_11, icd_12, icd_13, icd_14, icd_15, icd_16,
		icd_17, icd_18, icd_19, icd_20, icd_21, icd_22, icd_23, icd_24
	FROM (
		SELECT 
			fs.Year, fs.Fin_Month,
			fs.Age, fs.POD,
			PRIMARYKEY_ID, EPISODES_ID, 
			code, 'icd_' + CAST(ICD_ID AS VARCHAR) AS ICD_ID
		FROM [Data_Store_SUS_Unified].[APC].[spell.episodes.clinical_coding.diagnosis.icd] icd
		LEFT JOIN [NCL].[dbo].[Maindata_FasterSUS_IP_all_93c] fs
		ON fs.eID = icd.PRIMARYKEY_ID
		WHERE ICD_ID <= 24
		AND YEAR IS NOT NULL
	) AS s
	PIVOT (
		MAX(code)
		FOR ICD_ID IN (
			icd_1, icd_2, icd_3, icd_4, icd_5, icd_6, icd_7, icd_8,
			icd_9, icd_10, icd_11, icd_12, icd_13, icd_14, icd_15, icd_16,
			icd_17, icd_18, icd_19, icd_20, icd_21, icd_22, icd_23, icd_24
		)
	) AS unpvt
) icd
ON icd.PRIMARYKEY_ID = opcs.PRIMARYKEY_ID
AND icd.EPISODES_ID = opcs.EPISODES_ID
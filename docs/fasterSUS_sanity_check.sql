-- Sanity check: Run on latest month to see live figures for activity. Typically expect 6000+ rows
-- If <100 rows returned then suggests ISL are performing maintenance with the dataset

SELECT * FROM ncl.dbo.Maindata_FasterSUS_IP_all_93c ip

--Check for closed spell
INNER JOIN [Data_Store_SUS_Unified].[APC].[spell] fss
ON ip.eID = fss.PRIMARYKEY_ID

--Check for Dominant episode
INNER JOIN [Data_Store_SUS_Unified].[APC].[spell.episodes] fsse
ON ip.eID = fsse.PRIMARYKEY_ID


WHERE year = '2023/24' AND Fin_Month = 4 and ProviderCode = 'RAL'
AND POD IN ('DC', 'EL')
--Filter on closed spells and the dominant episode
AND fss.[spell.open_spell_indicator] = 0
AND fsse.[dominant_episode_flag] = 1

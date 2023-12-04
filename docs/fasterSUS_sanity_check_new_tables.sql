-- Sanity check: Run on latest month to see live figures for activity. Typically expect 6000+ rows

SELECT fin_year, fin_month, COUNT(1) FROM [Data_Lab_NCL_Test].[Current].[maindata_fs_ip] ip

--Check for closed spell
INNER JOIN [Data_Store_SUS_Unified].[APC].[spell] fss
ON ip.primary_id = fss.PRIMARYKEY_ID

--Check for Dominant episode
INNER JOIN [Data_Store_SUS_Unified].[APC].[spell.episodes] fsse
ON ip.primary_id = fsse.PRIMARYKEY_ID


WHERE fin_year = '2023/24' and provider_code = 'RAL'
AND POD IN ('DC', 'EL')
--Filter on closed spells and the dominant episode
AND fss.[spell.open_spell_indicator] = 0
AND fsse.[dominant_episode_flag] = 1

GROUP BY fin_year, Fin_Month

ORDER BY Fin_Month

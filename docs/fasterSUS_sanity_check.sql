-- Sanity check: Run on latest month to see live figures for activity. Typically expect 6000+ rows

SELECT year, Fin_Month, COUNT(1) FROM ncl.dbo.Maindata_FasterSUS_IP_all_93c ip

--Check for closed spell
INNER JOIN [Data_Store_SUS_Unified].[APC].[spell] fss
ON ip.eID = fss.PRIMARYKEY_ID

--Check for Dominant episode
INNER JOIN [Data_Store_SUS_Unified].[APC].[spell.episodes] fsse
ON ip.eID = fsse.PRIMARYKEY_ID


WHERE year = '2023/24' and ProviderCode = 'RAL'
AND POD IN ('DC', 'EL')
--Filter on closed spells and the dominant episode
AND fss.[spell.open_spell_indicator] = 0
AND fsse.[dominant_episode_flag] = 1

GROUP BY year, Fin_Month

ORDER BY Fin_Month

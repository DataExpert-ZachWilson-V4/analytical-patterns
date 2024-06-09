--Write a query (query_5) to answer: "Which team has won the most games"
SELECT 
  team_abbr,
  season,
  ttl_wins
FROM 
  faraanakmirzaei15025.nba_stats_summary
WHERE 
  season = 'overall' 
  AND player_name = 'overall'
ORDER BY 
  ttl_wins DESC 
LIMIT 1
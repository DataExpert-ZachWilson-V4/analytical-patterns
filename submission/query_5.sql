SELECT 
  team_abbr,
  season,
  ttl_wins
FROM 
  kmbarth.nba_stats_summary
WHERE 
  season = 'overall' 
  AND player_name = 'overall'
ORDER BY 
  ttl_wins DESC 
LIMIT 1
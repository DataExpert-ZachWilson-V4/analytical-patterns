SELECT 
  team_abbr,
  season,
  team_wins
FROM 
  kmbarth.nba_stats_summary
WHERE 
  season = 'overall' 
  AND player_name = 'overall'
ORDER BY 
  team_wins DESC 
LIMIT 1
SELECT 
  player_name,
  team_abbr,
  ttl_points_score
FROM 
  kmbarth.nba_stats_summary 
WHERE 
  season = 'overall' 
  AND player_name <> 'overall' 
  AND team_abbr <> 'overall'
ORDER BY 
  ttl_points_score DESC 
LIMIT 1
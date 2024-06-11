SELECT 
  player_name,
  season,
  ttl_points_scored  
FROM 
  kmbarth.nba_stats_summary
WHERE 
  season <> 'overall' 
  AND player_name <> 'overall'
ORDER BY 
  ttl_points_scored DESC 
LIMIT 1
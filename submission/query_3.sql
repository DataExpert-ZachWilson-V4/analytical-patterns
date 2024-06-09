--Write a query (query_3) to answer: "Which player scored the most points playing for a single team?"
SELECT 
  player_name,
  team_abbr,
  ttl_points_score
FROM 
  faraanakmirzaei15025.nba_stats_summary 
WHERE 
  season = 'overall' 
  AND player_name <> 'overall' 
  AND team_abbr <> 'overall'
ORDER BY 
  ttl_points_score DESC 
LIMIT 1;

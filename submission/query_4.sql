--Write a query (query_4) to answer: "Which player scored the most points in one season?"
SELECT 
  player_name,
  season,
  ttl_points_score  
FROM 
  faraanakmirzaei15025.nba_stats_summary
WHERE 
  season <> 'overall' 
  AND player_name <> 'overall'
ORDER BY 
  ttl_points_score DESC 
LIMIT 1
SELECT player, team, total_points
FROM game_details_dashboard
WHERE aggregation_level = 'team' 
AND total_points IS NOT NULL
ORDER BY total_points DESC 
LIMIT 1
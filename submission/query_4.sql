SELECT player, team, total_points
FROM pratzo.game_details_dashboard
WHERE aggregation_level = 'player_season' 
AND total_points IS NOT NULL
ORDER BY total_points DESC 
LIMIT 1
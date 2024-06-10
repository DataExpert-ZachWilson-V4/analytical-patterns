-- Which player scored the most points playing for a single team?

SELECT player, team, total_points
FROM game_details_dashboard
WHERE aggregation_level = 'player_team' 
AND total_points IS NOT NULL
ORDER BY total_points DESC 
LIMIT 1
-- Which player scored the most points in one season?
SET @aggregation_level = 'player_season';

SELECT player, team, total_points
FROM game_details_dashboard
WHERE aggregation_level = @aggregation_level 
AND total_points IS NOT NULL
ORDER BY total_points DESC 
LIMIT 1
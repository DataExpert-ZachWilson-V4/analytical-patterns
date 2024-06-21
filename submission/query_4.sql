-- Which player scored the most points in one season?
--

SELECT player, season, total_points
FROM jimmybrock65656.grouping_sets_nba
WHERE aggregation_level = 'player_season' 
AND total_points IS NOT NULL
AND player IS NOT NULL
AND season IS NOT NULL
ORDER BY total_points DESC
LIMIT 1
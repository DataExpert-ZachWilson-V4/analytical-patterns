-- Select the player, team, and total points from the game_details_dashboard table
SELECT player, team, total_points
FROM game_details_dashboard
-- Filter the results to only include player_season aggregation level
WHERE aggregation_level = 'player_season'
-- Exclude rows where total_points is NULL
AND total_points IS NOT NULL
-- Sort the results in descending order based on total_points
ORDER BY total_points DESC 
-- Limit the result set to only one row
LIMIT 1
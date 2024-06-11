-- Select the player, team, and total_points columns
SELECT player, team, total_points
FROM game_details_dashboard

-- Filter the results to only include rows where aggregation_level is 'player_team'
-- and total_points is not NULL
WHERE aggregation_level = 'player_team' 
AND total_points IS NOT NULL

-- Sort the results in descending order based on total_points
ORDER BY total_points DESC 

-- Limit the result set to only include the top 1 row
LIMIT 1
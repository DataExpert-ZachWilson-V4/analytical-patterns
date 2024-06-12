-- This query is showing the dataset in order of player who has 
-- most points also adding limit as we just need one record

SELECT player, team, total_points
FROM sagararora492.grouping_sets
WHERE aggregation_level = 'player_team' 
ORDER BY total_points DESC
LIMIT 1


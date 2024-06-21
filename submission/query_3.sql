-- Which player scored the most points 
-- playing for a single team?

SELECT  player AS player_name, 
        team AS team_name, 
        total_points AS  total_player_points
FROM jimmybrock65656.grouping_sets_nba
WHERE aggregation_level = 'player_team' 
AND total_points IS NOT NULL
ORDER BY total_points DESC 
LIMIT 1
-- Example output LeBron James, Cleveland Cavaliers
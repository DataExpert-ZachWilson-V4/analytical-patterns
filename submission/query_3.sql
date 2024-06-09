-- Which player scored the most points playing for a single team?
SELECT player, team, total_points
FROM jimmybrock65656.grouping_sets_nba
WHERE aggregation_level = 'player_team' 
ORDER BY total_points DESC 
LIMIT 1
-- LeBron James, Cleveland Cavaliers
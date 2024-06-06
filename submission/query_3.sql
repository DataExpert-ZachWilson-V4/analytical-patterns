SELECT player, team, total_points
FROM jsgomez14.grouping_sets_hw5
WHERE aggregation_level = 'player_team' 
ORDER BY total_points DESC 
-- LeBron James for Cleveland Cavaliers
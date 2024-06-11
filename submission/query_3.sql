SELECT player, team, total_points
FROM sagararora492.grouping_sets
WHERE aggregation_level = 'player_team' 
ORDER BY total_points DESC 
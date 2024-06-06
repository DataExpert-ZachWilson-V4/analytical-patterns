SELECT player, season, total_points
FROM jsgomez14.grouping_sets_hw5
WHERE aggregation_level = 'player_season'
ORDER BY total_points DESC
-- Kevin Durant in 2013 season
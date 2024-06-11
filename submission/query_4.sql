SELECT player, season, total_points
FROM sagararora492.grouping_sets
WHERE aggregation_level = 'player_season'
ORDER BY total_points DESC
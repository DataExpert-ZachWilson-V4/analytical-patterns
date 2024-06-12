-- This gets the dataset in order of player who has highest points per season

SELECT player, season, total_points
FROM sagararora492.grouping_sets
WHERE aggregation_level = 'player_season'
ORDER BY total_points DESC
LIMIT 1;
SELECT player, season, total_points
FROM adbeyer.nba_grouped_sets
WHERE aggregation_level = 'player_and_season'
ORDER BY total_points DESC --Kevin Durant 2013
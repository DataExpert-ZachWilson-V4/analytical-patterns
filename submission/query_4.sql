"""
    Which player scored the most points in one season?
"""
SELECT player, season, total_points
FROM jimmybrock65656.grouping_sets_nba
WHERE aggregation_level = 'player_season'
ORDER BY total_points DESC
LIMIT 1
-- Kevin Durant
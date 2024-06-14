--
-- Query 4: Which player scored the most points in one season?
--
-- player_name	season	max_points
-- Kevin Durant	2013	3265
--
SELECT
    player_name,
    season,
    MAX(total_points) AS max_points
FROM
    vzucher.nba_grouping_sets
WHERE
    aggregation_level = 'player_season'
GROUP BY
    player_name,
    season
ORDER BY
    max_points DESC
LIMIT 1
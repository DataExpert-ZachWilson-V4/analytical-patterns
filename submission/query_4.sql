-- Which player scored the most points in one season?
SELECT
    player_name,
    season,
    points
FROM
    akshayjainytl54781.nba_grouping_sets
    -- aggregation level is "player_and_season" and points is not NULL
WHERE
    aggregation_level = 'player_and_season'
    AND points IS NOT NULL
ORDER BY points DESC
LIMIT 1
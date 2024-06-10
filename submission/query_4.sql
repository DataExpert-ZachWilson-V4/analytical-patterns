---Write a query (query_4) to answer: "Which player scored the most points in one season?"
SELECT
    player_name,
    season,
    points
FROM
    nancyatienno21998.nba_grouping_sets
    -- aggregation level for "player_and_season" and points is not NULL
WHERE
    aggregation_level = 'player_and_season'
    AND points IS NOT NULL
ORDER BY points DESC
LIMIT 1
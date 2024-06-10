-- Which player scored the most points playing for a single team?
SELECT
    player_name,
    team,
    points
FROM
    akshayjainytl54781.nba_grouping_sets
    -- Select only 'player_and_team' agg level and points is not NULL
WHERE
    aggregation_level = 'player_and_team'
    AND points IS NOT NULL
ORDER BY
    points DESC
LIMIT
    1
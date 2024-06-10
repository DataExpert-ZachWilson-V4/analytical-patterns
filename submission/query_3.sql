--- Build additional queries on top of the results of the GROUPING SETS aggregations above to answer the following questions:
--- Write a query (query_3) to answer:
    --- "Which player scored the most points playing for a single team?"

SELECT
    player_name,
    team,
    points
FROM
    nancyatienno21998.nba_grouping_sets
    -- Select only 'player_and_team' agg level and points is not NULL
WHERE
    aggregation_level = 'player_and_team'
    AND points IS NOT NULL
ORDER BY
    points DESC
LIMIT
    1
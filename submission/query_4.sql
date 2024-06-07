-- query to answer: "Which player scored the most points in one season?"
SELECT
    player_name,
    season,
    points
FROM
    mariavyso.nba_grouping_sets
    -- filter the results to include only records 
    -- where the aggregation level is 'player_and_season' and points is not NULL
WHERE
    aggregation_level = 'player_and_season'
    AND points IS NOT NULL
    -- order the results by points in descending order
ORDER BY
    points DESC
    -- limit the results to the top 1 record
LIMIT
    1 -- the answer is Kevin Durant for 2013 season

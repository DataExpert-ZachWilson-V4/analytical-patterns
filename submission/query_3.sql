-- query to answer: "Which player scored the most points playing for a single team?"
SELECT
    player_name,
    team,
    points
FROM
    mariavyso.nba_grouping_sets
    -- filter the results to include only records where the aggregation level is 'player_and_team' and points is not NULL
WHERE
    aggregation_level = 'player_and_team'
    AND points IS NOT NULL
    -- order the results by points in descending order
ORDER BY
    points DESC
    -- limit the results to the top 1 record
LIMIT
    1 -- the answer is LeBron James for CLE

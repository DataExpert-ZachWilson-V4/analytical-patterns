--- Write a query (query_5) to answer: "Which team has won the most games"
SELECT
    team,
    games_won
FROM
    nancyatienno21998.nba_grouping_sets
    -- aggregation level = 'team' and games_won is not NULL
WHERE
    aggregation_level = 'team'
    AND games_won IS NOT NULL
ORDER BY
    games_won DESC
LIMIT
    1
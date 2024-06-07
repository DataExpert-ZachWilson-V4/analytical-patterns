-- query to answer: "Which team has won the most games?"
SELECT
    team,
    games_won
FROM
    mariavyso.nba_grouping_sets
    -- filter the results to include only records 
    -- where the aggregation level is 'team' and games_won is not NULL
WHERE
    aggregation_level = 'team'
    AND games_won IS NOT NULL
    -- order the results by games_won in descending order
ORDER BY
    games_won DESC
    -- limit the results to the top 1 record
LIMIT
    1

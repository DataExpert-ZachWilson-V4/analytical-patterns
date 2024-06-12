-- This query gets the dataset which team has won the most games
WITH query_5 AS (
    SELECT team, won_games
    FROM sagararora492.grouping_sets
    WHERE aggregation_level = 'team'
    ORDER BY won_games DESC
)
SELECT * FROM query_5;
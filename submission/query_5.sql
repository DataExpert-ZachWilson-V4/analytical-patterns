- Build additional queries on top of the results of the `GROUPING SETS` aggregations above to answer the following questions:
  - Write a query (`query_3`) to answer: "Which player scored the most points playing for a single team?"
  - Write a query (`query_4`) to answer: "Which player scored the most points in one season?"
  - Write a query (`query_5`) to answer: "Which team has won the most games"
*/

-- query from the dashboard dataset created in Query 2
SELECT team, won_games
FROM bhakti.nba_games_details_board
WHERE aggregation_level = 'team'
ORDER BY won_games DESC
LIMIT 1

/*
Result : SAS (Spurs)
team	won_games
SAS	    14881
*/
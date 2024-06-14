/*
Build additional queries on top of the results of the `GROUPING SETS` aggregations above to answer the following questions:
  - Write a query (`query_3`) to answer: "Which player scored the most points playing for a single team?"
  - Write a query (`query_4`) to answer: "Which player scored the most points in one season?"
  - Write a query (`query_5`) to answer: "Which team has won the most games"

*/

SELECT player, season, total_points
FROM harathi.nba_games_details_board
WHERE aggregation_level = 'player_and_season'
ORDER BY total_points DESC 
LIMIT 1

/*
Results:

player	        season	total_points
Kevin Durant	2013	3265
*/

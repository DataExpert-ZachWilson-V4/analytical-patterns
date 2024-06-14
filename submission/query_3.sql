/*
- Build additional queries on top of the results of the `GROUPING SETS` aggregations above to answer the following questions:
  - Write a query (`query_3`) to answer: "Which player scored the most points playing for a single team?"
  - Write a query (`query_4`) to answer: "Which player scored the most points in one season?"
  - Write a query (`query_5`) to answer: "Which team has won the most games"

*/

SELECT player, team, total_points
FROM harathi.nba_games_details_board
WHERE aggregation_level = 'player_and_team' 
ORDER BY total_points DESC
LIMIT 1

/* 
Result: LeBron James

player	        team	total_points
LeBron James	CLE	    28314 
*/

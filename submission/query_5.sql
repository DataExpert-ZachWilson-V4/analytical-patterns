---- This query is to find the team(s) with the most wins


WITH teams_ranked_by_wins AS
(
---- Use DENSE_RANK() to rank teams by their number of wins
SELECT 
  team,
  team_wins,
  DENSE_RANK() OVER(ORDER BY team_wins DESC) AS rnk 
FROM hdamerla.nba_grouping_sets WHERE 
aggregation_level = 'Team'  AND team_wins IS NOT NULL
    AND team IS NOT NULL
)

---- Modify the final SELECT to return all teams with the highest number of wins
SELECT 
  team,
  team_wins
FROM teams_ranked_by_wins WHERE rnk = 1

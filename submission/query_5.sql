---- This query is to find the team(s) with the most wins


WITH teams_ranked_by_wins AS
(
SELECT 
  team,
  team_wins,
  DENSE_RANK() OVER(ORDER BY team_wins DESC) AS rnk 
FROM hdamerla.nba_grouping_sets WHERE 
aggregation_level = 'Team' and team_wins is not null
)

---- Modify the final SELECT to return all teams with the highest number of wins
SELECT 
  team,
  team_wins
FROM teams_ranked_by_wins WHERE rnk = 1

WITH team_wins_agg AS
(
SELECT 
  team,
  total_wins,
  Dense_Rank() OVER(ORDER BY total_wins DESC) AS rnk -- Logic to avoid reading the table twice by first fetching the max points and using that as filter. Rather reading the data on a whole and applying the window function.
FROM Jaswanthv.nba_games_aggregate WHERE 
aggregation_level = 'Team'
)
SELECT 
  team,
  total_wins
FROM team_wins_agg WHERE rnk = 1

-- SAS	14867
